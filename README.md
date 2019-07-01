# Podman images

## Podman

[![CircleCI](https://img.shields.io/circleci/build/github/marshallford/podman.svg)](https://circleci.com/gh/marshallford/podman)
[![Registry](https://img.shields.io/badge/registry-docker.io-blue.svg)](https://hub.docker.com/r/marshallford/podman)
[![Image Layers](https://images.microbadger.com/badges/image/marshallford/podman.svg)](https://microbadger.com/images/marshallford/podman)

```
docker pull marshallford/podman:TAG
```

```
docker run --privileged -v /tmp/podman:/var/lib/containers marshallford/podman:latest \
run alpine echo hello from alpine in podman container
```

## Podman Remote

[![CircleCI](https://img.shields.io/circleci/build/github/marshallford/podman.svg)](https://circleci.com/gh/marshallford/podman)
[![Registry](https://img.shields.io/badge/registry-docker.io-blue.svg)](https://hub.docker.com/r/marshallford/podman-remote)
[![Image Layers](https://images.microbadger.com/badges/image/marshallford/podman-remote.svg)](https://microbadger.com/images/marshallford/podman-remote)

```
docker pull marshallford/podman-remote:TAG
```

```
docker run marshallford/podman-remote:latest \
PODMAN_VARLINK_ADDRESS="tcp:127.0.0.1:1234" podman-remote images
```
