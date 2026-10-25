# nextcloud

The official `nextcloud:<version>-fpm-alpine` image plus `ffmpeg` and `exiftool`.

The official image does not ship them, and they are needed for video thumbnails
and for the [Memories](https://memories.gallery) photo app.

- Tags: `<version>` (for example `35.0.2`) and `rolling`. The flavor is always fpm-alpine, run it with an nginx sidecar.
- `ci/latest.sh` follows one Nextcloud major line only (`MAJOR` in the script), because Nextcloud upgrades one major at a time. Bump it deliberately.
- Platform: `linux/amd64`.
