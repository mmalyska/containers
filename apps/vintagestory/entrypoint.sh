#!/bin/sh

echo "Starting application"
exec dotnet VintagestoryServer.dll --dataPath "$DATA_PATH" "$@"
