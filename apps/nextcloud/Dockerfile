ARG VERSION
FROM docker.io/library/nextcloud:${VERSION}-fpm-alpine

# ffmpeg/ffprobe: video previews and Memories transcoding.
# exiftool: Memories reads photo/video metadata (dates, location, motion photos) with it.
# imagemagick-heic: the official image's ImageMagick has no HEIC coder, so Samsung/HEIC
# photos get no thumbnail. Alpine splits that coder (and libheif) into its own package.
# None of these ship in the official image.
RUN apk add --no-cache ffmpeg exiftool imagemagick-heic
