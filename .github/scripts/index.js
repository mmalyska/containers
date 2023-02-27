const fs = require('fs'); 
const glob = require('@actions/glob');
const metadataGlobber = await glob.create('apps/*/metadata.json');

const fetchChanges = async (context, github, core, appname) => {
  let changes = [];

  for await (const file of metadataGlobber.globGenerator()) {
    let {app, channels} = await fs.readJson(file);

    for (const channel of channels) {
      let publishedVersion = await published(context, github, core, app, channel.name, channel.stable);
      let upstreamVersion = await upstream(app, channel.name, channel.stable);

      if (publishedVersion != upstreamVersion.stdout) {
        changes.push({"app": app, "channel": channel.name, "version": upstreamVersion});
      }
    }
  }

  core.setOutput('changes', JSON.stringify(changes));
};

const upstream = async (app, channel, stable) => {
  let version = '';
  try {
    await fs.promises.access(`./apps/"${app}"/ci/latest.sh`);
    version = await $`bash ./apps/"${app}"/ci/latest.sh "${channel}"`;
  } catch {
    version = 'UNKNOWN';
  }
  return version;
};

const published = async (context, github, core, app, channel, stable) => {
  app = (stable ? app : `${app}-${channel}`);
  let res = await github.rest.packages.getAllPackageVersionsForPackageOwnedByUser({
    package_type: 'container',
    package_name: app,
    username: context.repo.owner,
  });
  try {
    // Assume first image found and first tag found is the most recent pushed tag
    return res[0].metadata.container.tags[0];
  } catch {
    console.log(`Error finding published version for ${app}`);
  }
};

module.exports = {
  fetchChanges,
  upstream,
  published,
};
