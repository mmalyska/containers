const fs = await import('fs'); 
const glob = await import('@actions/glob');
const allMetadataGlobber = await glob.create('./apps/*/metadata.json');

export const changes = async (context, github, core, all = false) => {
  let changes = [];

  for await (const file of allMetadataGlobber.globGenerator()) {
    let {app, channels} = await fs.readJson(file);

    for (const channel of channels) {
      let publishedVersion = await published(context, github, core, app, channel.name, channel.stable);
      let upstreamVersion = await upstream(app, channel.name, channel.stable);

      if (all) {
        changes.push({"app": app, "channel": channel.name, "version": upstreamVersion});
      }
      else if (publishedVersion != upstreamVersion.stdout) {
        changes.push({"app": app, "channel": channel.name, "version": upstreamVersion});
      }
    }
  }

  core.setOutput('changes', JSON.stringify(changes));
};

export const appChanges = async (core, apps, overrideChannels) => {
  let changes = [];

  for await (const app of apps) {
    let channels = [];
    if (overrideChannels) {
      channels = overrideChannels;
    } else {
      channels = await fs.readJson(`apps/"${app}"/metadata.json`);
    }

    for (const channel of channels) {
      let upstreamVersion = await upstream(app, channel.name, channel.stable);
      changes.push({"app": app, "channel": channel.name, "version": upstreamVersion});
    }
  }

  core.setOutput('changes', JSON.stringify(changes));
};

const upstream = async (app, channel, stable) => {
  let version = '';
  try {
    await fs.promises.access(`./apps/"${app}"/ci/latest.sh`);
    version = await $`bash ./apps/"${app}"/ci/latest.sh "${channel}" "${stable}"`;
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
    const rollingContainer = res.find(e => e.metadata.container.tags.includes("rolling"));
    return rollingContainer.metadata.container.tags.find(e => e != "rolling");
  } catch {
    console.log(`Error finding published version for ${app}`);
  }
};
