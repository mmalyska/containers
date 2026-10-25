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
