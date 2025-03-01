import fs from "fs";
import { execSync } from "child_process";

export const changes = async (glob, context, github, core, all = false) => {
  let changes = [];
  let allMetadataGlobber = await glob.create('./apps/*/metadata.json');

  for await (const file of allMetadataGlobber.globGenerator()) {
    let channelsFile = await fs.promises.readFile(file);
    let { app, channels } = JSON.parse(channelsFile);

    for (const channel of channels) {
      let {found: publishedFound, version: publishedVersion} = await published(context, github, core, app, channel.name, channel.stable) || {};
      let upstreamVersion = await upstream(app, channel.name, channel.stable);
      let change = { "app": app, "channel": channel.name, "version": upstreamVersion };
      if (upstreamVersion == null || publishedVersion == null) {
        continue;
      }
      if (all) {
        changes.push(change);
        console.log(`Pushed changes "app": ${app}, "channel": ${channel.name}, "version": ${upstreamVersion}, "published": ${publishedVersion}`);
      }
      else if (!publishedFound || publishedVersion != upstreamVersion) {
        changes.push(change);
        console.log(`Pushed changes "app": ${app}, "channel": ${channel.name}, "version": ${upstreamVersion}, "published": ${publishedVersion}`);
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
      let channelsFile = await fs.promises.readFile(`./apps/${app}/metadata.json`);
      channels = JSON.parse(channelsFile).channels;
    }

    for (const channel of channels) {
      let upstreamVersion = await upstream(app, channel.name, channel.stable);
      if (upstreamVersion == null) {
        continue;
      }
      let change = { "app": app, "channel": channel.name, "version": upstreamVersion };
      console.log(`Pushed changes "app": ${app}, "channel": ${channel.name}, "version": ${upstreamVersion}`);
      changes.push(change);
    }
  }

  core.setOutput('changes', JSON.stringify(changes));
};

const upstream = async (app, channel, stable) => {
  try {
    await fs.promises.access(`./apps/${app}/ci/latest.sh`);
    let result = execSync(`./apps/${app}/ci/latest.sh "${channel}" "${stable}"`).toString();
    if (result == 'null' || result == '') {
      return null;
    }
    return result;
  } catch (error) {
    console.log(`Error finding upstream version for ${app}`);
    return null;
  }
};

const published = async (context, github, core, app, channel, stable) => {
  app = (stable ? app : `${app}-${channel}`);
  try {
    let { data: versions } = await github.rest.packages.getAllPackageVersionsForPackageOwnedByUser({
      package_type: 'container',
      package_name: app,
      username: context.repo.owner,
    });
    const rollingContainer = versions.find(e => e.metadata.container.tags.includes("rolling"));
    if (rollingContainer == null) {
      return { found: false, version: '-1' };
    }
    return { found: true, version: rollingContainer.metadata.container.tags.find(e => e != "rolling") };
  } catch (error) {
    if (error.status === 404) {
      return { found: false, version: '-1' };
    } else {
      console.log(`Error finding published version for ${app}`);
      return null;
    }
  }
};
