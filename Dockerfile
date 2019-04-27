FROM fedora:29
LABEL maintainer="Marshall Ford <inbox@marshallford.me>"

ARG BUILD_DATE
ARG VCS_REF
ARG PODMAN_VERSION
ARG IMAGE_NAME

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$PODMAN_VERSION \
      org.label-schema.name=$IMAGE_NAME \
      org.label-schema.vcs-url="https://github.com/marshallford/podman" \
      org.label-schema.url="https://podman.io"

RUN dnf upgrade -y && dnf install -y podman-$PODMAN_VERSION && dnf clean all -y

ENTRYPOINT ["podman"]
CMD ["help"]
