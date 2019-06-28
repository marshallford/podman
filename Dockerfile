FROM golang:1.12.6-alpine3.10 AS builder

ARG CONMON_VERSION
ARG RUNC_VERSION
ARG CNI_PLUGINS_VERSION
ARG PODMAN_VERSION

RUN apk --no-cache add bash btrfs-progs-dev build-base device-mapper git glib-dev go-md2man gpgme-dev ip6tables libassuan-dev libseccomp-dev libselinux-dev lvm2-dev openssl ostree-dev pkgconf protobuf-c-dev protobuf-dev

RUN git clone --branch v$CONMON_VERSION https://github.com/containers/conmon $GOPATH/src/github.com/containers/conmon && \
    cd $GOPATH/src/github.com/containers/conmon && make
RUN git clone --branch v$RUNC_VERSION https://github.com/opencontainers/runc $GOPATH/src/github.com/opencontainers/runc && \
    cd $GOPATH/src/github.com/opencontainers/runc && make BUILDTAGS="seccomp apparmor selinux ambient"
RUN git clone --branch v$CNI_PLUGINS_VERSION https://github.com/containernetworking/plugins $GOPATH/src/github.com/containernetworking/plugins && \
    cd $GOPATH/src/github.com/containernetworking/plugins && ./build_linux.sh
RUN git clone --branch v$PODMAN_VERSION https://github.com/containers/libpod $GOPATH/src/github.com/containers/libpod && \
    cd $GOPATH/src/github.com/containers/libpod && make BUILDTAGS="selinux seccomp apparmor"

FROM alpine:3.10.0

ARG BUILD_DATE
ARG VCS_REF
ARG PODMAN_VERSION
ARG IMAGE_NAME

LABEL maintainer="Marshall Ford <inbox@marshallford.me>"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$PODMAN_VERSION \
      org.label-schema.name=$IMAGE_NAME \
      org.label-schema.vcs-url="https://github.com/marshallford/podman" \
      org.label-schema.url="https://podman.io"

RUN apk --no-cache add device-mapper gpgme ip6tables libseccomp libselinux ostree

COPY --from=builder /go/src/github.com/containers/conmon/bin/ /usr/bin/
COPY --from=builder /go/src/github.com/opencontainers/runc/runc /usr/bin/
COPY --from=builder /go/src/github.com/containernetworking/plugins/bin/ /usr/lib/cni/
COPY --from=builder /go/src/github.com/containers/libpod/bin/ /usr/bin/

COPY files/87-podman-bridge.conflist /etc/cni/net.d/
COPY files/registries.conf files/policy.json files/storage.conf /etc/containers/
COPY files/libpod.conf /usr/share/containers/libpod.conf

ENTRYPOINT ["podman"]
CMD ["help"]
