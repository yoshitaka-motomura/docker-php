IMAGE_NAME=staydaybreak/php
IMAGE_TAG=8.2.8-fpm-alpine
buildx:
	@docker buildx build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile . --push

build:
	@docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile . --no-cache

scout:
	@docker scout quickview $(IMAGE_NAME):$(IMAGE_TAG)
	@docker scout cves $(IMAGE_NAME):$(IMAGE_TAG)
push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)
