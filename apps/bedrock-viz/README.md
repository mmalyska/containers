# bedrock-viz Container
The container is build for generating Minecraft Bedrock maps using https://github.com/bedrock-viz/bedrock-viz
## Usage
### Mounts

| Name       | Description                                   |
|------------|-----------------------------------------------|
| `/world`   | Directory containing world files              |
| `/out`     | Directory with output map                     |


### Enviroment variables
To pass additional parameters to application add them to args when executing container.

| Name                   | Description                        | Default      |
|------------------------|------------------------------------|--------------|
| `BEDROCKVIZ__OPTION`   | Additional options to pass to app  | `--html-all` |

### Docker run
To run this in docker, mount volumes with world and empty one for output files.
```sh
docker run --rm -e BEDROCKVIZ__OPTION=--html-most -v /path/to/public_html:/out -v /path/to/world:/world dazworrall/bedrock-viz
```

### Docker compose
```yml
services:
  bedrock-viz:
      image: ghcr.io/mmalyska/bedrock-viz:rolling@sha256:COMMIT_SHA
      container_name: bedrock-viz
      environment:
        - BEDROCKVIZ__OPTION=--html-all
      volumes:
        - ./jaskinia:/world:ro
        - ./output:/out
```
