cnf ?= config.env
include $(cnf)

default: build

GIT_BRANCH ?= `git rev-parse --abbrev-ref HEAD`
GIT_COMMIT ?= `git rev-parse --short HEAD`

ifeq ($(GIT_BRANCH), master)
  IMAGE_TAG = $(PODMAN_VERSION)
  PUSH_LATEST_TAG = true
else
  IMAGE_TAG = $(GIT_COMMIT)
endif

IMAGE_NAME = $(IMAGE_NAME_PREFIX)/podman
RUN = docker run --rm --privileged -v /tmp/podman:/var/lib/containers
PODMAN_RUN = $(RUN) $(IMAGE_NAME):latest

build: build/podman build/podman-remote

build/podman build/podman-remote:
	sed 's/<BIN>/$(@F)/g' Dockerfile | docker build -f - \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=$(GIT_COMMIT) \
		--build-arg CONMON_VERSION=$(CONMON_VERSION) \
		--build-arg RUNC_VERSION=$(RUNC_VERSION) \
		--build-arg CNI_PLUGINS_VERSION=$(CNI_PLUGINS_VERSION) \
		--build-arg PODMAN_VERSION=$(PODMAN_VERSION) \
		--build-arg IMAGE_NAME=$(IMAGE_NAME_PREFIX)/$(@F) \
		-t $(IMAGE_NAME_PREFIX)/$(@F):$(GIT_COMMIT) \
		-t $(IMAGE_NAME_PREFIX)/$(@F):$(IMAGE_TAG) \
		-t $(IMAGE_NAME_PREFIX)/$(@F):latest .

push: push/podman push/podman-remote

push/podman push/podman-remote:
	docker push $(IMAGE_NAME_PREFIX)/$(@F):$(IMAGE_TAG)
	if [ -n "$(PUSH_LATEST_TAG)" ]; then docker push $(IMAGE_NAME_PREFIX)/$(@F):latest; fi

run:
	$(RUN) -it --entrypoint=/bin/sh $(IMAGE_NAME):latest

version:
	$(PODMAN_RUN) version

info:
	$(PODMAN_RUN) info

test:
	$(PODMAN_RUN) run --rm alpine echo hello from alpine in podman container

dive:
	docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:v0.7.2 $(IMAGE_NAME):latest

.PHONY: \
	build \
	build/podman \
	build/podman-remote \
	push \
	push/podman\
	push/podman-remote \
	run \
	version \
	info \
	test \
	dive
