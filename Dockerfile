FROM golang:1.12.7-alpine3.10 AS builder

ARG CONMON_VERSION
ARG RUNC_VERSION
ARG CNI_PLUGINS_VERSION
ARG PODMAN_VERSION

RUN apk --no-cache add bash btrfs-progs-dev build-base device-mapper git glib-dev go-md2man gpgme-dev ip6tables libassuan-dev libseccomp-dev libselinux-dev lvm2-dev openssl ostree-dev pkgconf protobuf-c-dev protobuf-dev
RUN git config --global advice.detachedHead false

RUN git clone --branch v$CONMON_VERSION https://github.com/containers/conmon $GOPATH/src/github.com/containers/conmon && \
    cd $GOPATH/src/github.com/containers/conmon && make
RUN git clone --branch v$RUNC_VERSION https://github.com/opencontainers/runc $GOPATH/src/github.com/opencontainers/runc && \
    cd $GOPATH/src/github.com/opencontainers/runc && EXTRA_LDFLAGS="-s -w" make BUILDTAGS="seccomp apparmor selinux ambient"
RUN git clone --branch v$CNI_PLUGINS_VERSION https://github.com/containernetworking/plugins $GOPATH/src/github.com/containernetworking/plugins && \
    cd $GOPATH/src/github.com/containernetworking/plugins && GOFLAGS="-ldflags=-s -ldflags=-w" ./build_linux.sh
RUN git clone --branch v$PODMAN_VERSION https://github.com/containers/libpod $GOPATH/src/github.com/containers/libpod && \
    cd $GOPATH/src/github.com/containers/libpod && LDFLAGS="-s -w" make varlink_generate <BIN> BUILDTAGS="selinux seccomp apparmor"

FROM alpine:3.10.1

ARG CREATED
ARG REVISION
ARG PODMAN_VERSION
ARG IMAGE_NAME

LABEL maintainer="Marshall Ford <inbox@marshallford.me>"

LABEL org.opencontainers.image.created=$CREATED \
      org.opencontainers.image.revision=$REVISION \
      org.opencontainers.image.version=$PODMAN_VERSION \
      org.opencontainers.image.title=$IMAGE_NAME \
      org.opencontainers.image.source="https://github.com/marshallford/podman" \
      org.opencontainers.image.url="https://podman.io"

RUN apk --no-cache add device-mapper gpgme ip6tables libseccomp libselinux ostree

COPY --from=builder /go/src/github.com/containers/conmon/bin/ /usr/bin/
COPY --from=builder /go/src/github.com/opencontainers/runc/runc /usr/bin/
COPY --from=builder /go/src/github.com/containernetworking/plugins/bin/ /usr/lib/cni/
COPY --from=builder /go/src/github.com/containers/libpod/bin/ /usr/bin/

COPY files/87-podman-bridge.conflist /etc/cni/net.d/
COPY files/libpod.conf files/registries.conf files/policy.json files/storage.conf /etc/containers/

ENTRYPOINT ["<BIN>"]
CMD ["help"]
