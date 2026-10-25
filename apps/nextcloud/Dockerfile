ARG VERSION
FROM docker.io/library/nextcloud:${VERSION}-fpm-alpine

# ffmpeg/ffprobe: video previews and Memories transcoding.
# exiftool: Memories reads photo/video metadata (dates, location, motion photos) with it.
# Neither ships in the official image.
RUN apk add --no-cache ffmpeg exiftool
