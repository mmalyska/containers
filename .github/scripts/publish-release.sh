#!/usr/bin/env bash
# Publishes the GitHub release of one image version, so Renovate PRs that move
# to that version carry release notes.
#
# Renovate reads `org.opencontainers.image.source` from the image, finds this
# repository, and matches the release tag `<image>-<version>` to the version.
#
# The release says what changed in the image: a link to the upstream notes
# (from `upstream` in metadata.json) and the commits to `apps/<app>/` since the
# image's previous release. A rebuild of a version that already has a release
# appends its commits to that release; the git tag is never moved.
#
# Every commit an image release covers is recorded as a `built-from` marker in
# its body: that is how the next build knows where to start.
#
# Environment:
#   APP          app directory under apps/
#   IMAGE_NAME   image name, e.g. s3-bucket-cleaner
#   VERSION      image version
#   IMAGE        image reference without tag, e.g. ghcr.io/mmalyska/s3-bucket-cleaner
#   SHA          commit the image was built from
#   RUN_URL      URL of the workflow run that built it
#   GITHUB_REPOSITORY, GITHUB_SERVER_URL   set by GitHub Actions
#   DRY_RUN      "true" to print the release instead of publishing it, and to
#                skip checking the registry for the image
set -euo pipefail

: "${APP:?}" "${IMAGE_NAME:?}" "${VERSION:?}" "${IMAGE:?}" "${SHA:?}" "${RUN_URL:?}" "${GITHUB_REPOSITORY:?}"
GITHUB_SERVER_URL="${GITHUB_SERVER_URL:-https://github.com}"
DRY_RUN="${DRY_RUN:-false}"

repo_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
tag="${IMAGE_NAME}-${VERSION}"
title="${IMAGE_NAME} ${VERSION}"
max_commits=100

# Only publish a release for an image this commit actually pushed: with
# fail-fast off, other images of the same run may have failed. The published
# revision label is the plain one for every image, base images included.
if [[ "${DRY_RUN}" != true ]]; then
  revision=$(docker buildx imagetools inspect "${IMAGE}:${VERSION}" --format '{{json .Image}}' |
    jq --raw-output '(if has("config") then . else first(.[]) end).config.Labels["org.opencontainers.image.revision"] // ""')
  if [[ "${revision}" != "${SHA}" ]]; then
    echo "::notice::${IMAGE}:${VERSION} was not pushed from ${SHA} (revision '${revision}'), no release published"
    exit 0
  fi
fi

# `@name` in a release body notifies that user: break it up.
no_mentions() { sed 's/@/@\xe2\x80\x8b/g'; }

# Commits to apps/<app>/ in (from, to], newest first, as a markdown list.
# Prints nothing when there are none.
commit_list() {
  local from="$1" to="$2" range
  range="${to}"
  [[ -n "${from}" ]] && range="${from}..${to}"
  git log --no-merges --max-count="$((max_commits + 1))" --format='%H%x09%s' "${range}" -- "apps/${APP}/" |
    no_mentions |
    awk -F '\t' -v url="${repo_url}" -v max="${max_commits}" '
      NR > max { print "- … more commits, see the comparison link"; exit }
      { printf "- [`%s`](%s/commit/%s) %s\n", substr($1, 1, 7), url, $1, $2 }'
}

commits_section() {
  local from="$1" to="$2" list
  if [[ -z "${from}" ]]; then
    echo "No earlier release of this image to compare with."
    return
  fi
  if ! git merge-base --is-ancestor "${from}" "${to}" 2>/dev/null; then
    echo "Cannot list commits: \`${from:0:7}\` is not an ancestor of \`${to:0:7}\`."
    return
  fi
  list=$(commit_list "${from}" "${to}")
  if [[ -z "${list}" ]]; then
    echo "No changes to \`apps/${APP}/\` since \`${from:0:7}\`."
  else
    echo "Commits to \`apps/${APP}/\` since \`${from:0:7}\` ([comparison](${repo_url}/compare/${from}...${to})):"
    echo
    echo "${list}"
  fi
}

last_built_from() { grep -o '<!-- built-from: [0-9a-f]\{40\} -->' | tail -n 1 | grep -o '[0-9a-f]\{40\}' || true; }

publish() {
  local mode="$1" notes_file="$2"
  if [[ "${DRY_RUN}" == true ]]; then
    echo "----- DRY RUN: would ${mode} release '${title}' (tag ${tag} at ${SHA}) -----"
    cat "${notes_file}"
    echo "----- end -----"
  elif [[ "${mode}" == create ]]; then
    gh release create "${tag}" --repo "${GITHUB_REPOSITORY}" --target "${SHA}" \
      --title "${title}" --notes-file "${notes_file}" --latest=false
  else
    gh release edit "${tag}" --repo "${GITHUB_REPOSITORY}" --notes-file "${notes_file}"
  fi
}

notes=$(mktemp)
trap 'rm -f "${notes}"' EXIT

existing=$(gh release view "${tag}" --repo "${GITHUB_REPOSITORY}" --json body --jq '.body' 2>/dev/null) && found=true || found=false

if [[ "${found}" == true ]]; then
  # Rebuild of a version that already has a release.
  if grep -q "<!-- built-from: ${SHA} -->" <<< "${existing}"; then
    echo "Release ${tag} already covers ${SHA}, nothing to do"
    exit 0
  fi
  previous_sha=$(last_built_from <<< "${existing}")
  {
    printf '%s\n\n' "${existing}"
    echo "### Rebuild from \`${SHA:0:7}\` ($(date --utc +%Y-%m-%d))"
    echo
    echo "Same version, rebuilt from [\`${SHA:0:7}\`](${repo_url}/commit/${SHA}) in [this run](${RUN_URL})."
    echo
    commits_section "${previous_sha}" "${SHA}"
    echo
    echo "<!-- built-from: ${SHA} -->"
  } > "${notes}"
  publish edit "${notes}"
  exit 0
fi

# The image's previous release: the newest one titled "<image> <version>".
previous=$(gh release list --repo "${GITHUB_REPOSITORY}" --limit 1000 --json tagName,name,createdAt |
  jq --compact-output --arg prefix "${IMAGE_NAME} " --arg tag "${tag}" '
    [.[] | select((.name | startswith($prefix)) and .tagName != $tag)]
    | sort_by(.createdAt) | last // empty')
previous_version=""
previous_sha=""
if [[ -n "${previous}" ]]; then
  previous_version=$(jq --raw-output '.name | sub("^[^ ]+ "; "")' <<< "${previous}")
  previous_tag=$(jq --raw-output '.tagName' <<< "${previous}")
  previous_sha=$(gh release view "${previous_tag}" --repo "${GITHUB_REPOSITORY}" --json body --jq '.body' | last_built_from)
fi

render() { sed -e "s|{version}|${VERSION}|g" -e "s|{previousVersion}|${previous_version}|g" <<< "$1"; }
release_notes_url=$(jq --raw-output '.upstream.releaseNotes // ""' "apps/${APP}/metadata.json")
compare_url=$(jq --raw-output '.upstream.compare // ""' "apps/${APP}/metadata.json")

{
  echo "Image \`${IMAGE}:${VERSION}\`, built from [\`${SHA:0:7}\`](${repo_url}/commit/${SHA}) in [this run](${RUN_URL})."
  echo
  echo "### Upstream"
  echo
  if [[ -z "${release_notes_url}" ]]; then
    echo "No upstream project: the image is built from this repository only."
  else
    echo "- Release notes for ${VERSION}: $(render "${release_notes_url}")"
    if [[ -n "${compare_url}" && -n "${previous_version}" && "${previous_version}" != "${VERSION}" ]]; then
      echo "- Changes since ${previous_version}: $(render "${compare_url}")"
    fi
  fi
  echo
  echo "### Changes in this repository"
  echo
  commits_section "${previous_sha}" "${SHA}"
  echo
  echo "<!-- built-from: ${SHA} -->"
} > "${notes}"

publish create "${notes}"
