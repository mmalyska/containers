# bedrock-viz Container
The container is build for generating Minecraft Bedrock maps using https://github.com/bedrock-viz/bedrock-viz
## Usage
### Mounts

| Name       | Description                                   |
|------------|-----------------------------------------------|
| `/world`    | Directory containing world files              |
| `/out`      | Directory with output map                     |


### Parameters
To pass additional parameters to application add them to args when executing container.

### Docker run
To run this in docker, mount volumes with world and empty one for output files. To generate all maps pass `--html-all` as additional arguments.
```sh
docker run --rm -v /path/to/public_html:/out -v /path/to/world:/world dazworrall/bedrock-viz --world /world --out /out --html-all
```

### Docker compose
```yml
services:
  bedrock-viz:
      image: ghcr.io/mmalyska/bedrock-viz:rolling@sha256:COMMIT_SHA
      container_name: bedrock-viz
      command: --html-all
      volumes:
        - ./jaskinia:/world:ro
        - ./output:/out

```
