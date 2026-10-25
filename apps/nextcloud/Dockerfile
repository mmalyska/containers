ARG VERSION
FROM docker.io/library/nextcloud:${VERSION}-fpm-alpine

# ffmpeg/ffprobe: video previews and Memories transcoding.
# exiftool: Memories reads photo/video metadata (dates, location, motion photos) with it.
# imagemagick-heic: the official image's ImageMagick has no HEIC coder, so Samsung/HEIC
# photos get no thumbnail. Alpine splits that coder (and libheif) into its own package.
# intel-media-driver: the VAAPI (iHD) driver for Intel Gen 9.5+ iGPUs, so Memories can
# transcode 4K HEVC on the GPU. libva-utils provides vainfo for checking it in the pod.
# None of these ship in the official image.
RUN apk add --no-cache ffmpeg exiftool imagemagick-heic intel-media-driver libva-utils

# Memories' go-vod calls this instead of ffmpeg (memories.vod.ffmpeg): it fixes the order of
# the HDR tone-mapping graph so 4K HLG video transcodes faster than real time.
COPY --chmod=755 apps/nextcloud/memories-ffmpeg /usr/local/bin/memories-ffmpeg
