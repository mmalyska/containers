#!/bin/sh

echo "Starting application"
exec ./VintagestoryServer --dataPath "$DATA_PATH" "$@"
