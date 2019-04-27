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
    -t $(IMAGE_NAME):latest \
    -t $(IMAGE_NAME):$(IMAGE_TAG) .

push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
	if [ -n "$(PUSH_LATEST_TAG)" ]; then docker push $(IMAGE_NAME):latest; fi

test:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) --version
