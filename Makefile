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

build:
	docker build \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --build-arg VCS_REF=$(GIT_COMMIT) \
    --build-arg PODMAN_VERSION=$(PODMAN_VERSION) \
    --build-arg IMAGE_NAME=$(IMAGE_NAME) \
		-t $(IMAGE_NAME):$(GIT_COMMIT) \
    -t $(IMAGE_NAME):$(IMAGE_TAG) \
		-t $(IMAGE_NAME):latest .

push:
	docker push $(IMAGE_NAME):$(GIT_COMMIT)
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
	if [ -n "$(PUSH_LATEST_TAG)" ]; then docker push $(IMAGE_NAME):latest; fi

version:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) --version

test:
	docker run --rm --privileged $(IMAGE_NAME):$(IMAGE_TAG) \
	--cgroup-manager cgroupfs --storage-driver vfs \
	run --rm alpine echo hello from alpine in podman container
