# Code-Server-Docker

## Docker Manifest

```shell
docker manifest create \
    rexezuge/code-server:<COMMIT-ID> \
    --amend rexezuge/code-server:<COMMIT-ID>-amd64 \
    --amend rexezuge/code-server:<COMMIT-ID>-arm64v8 \
&& docker manifest push rexezuge/code-server:<COMMIT-ID>
```
