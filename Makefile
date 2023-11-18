include .env
export $(shell sed 's/=.*//' .env)
build:
	@make auth
	@if [ -z "$(IMAGE_TAG)" ]; then \
		IMAGE_TAG=latest; \
	fi
	@if [ -z "$(IMAGE_NAME)" ]; then \
		echo "IMAGE_NAME is empty"; \
		exit 1; \
	fi

	@docker buildx build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile . --push
scout:
	@docker scout quickview $(IMAGE_NAME):$(IMAGE_TAG)
	@docker scout cves $(IMAGE_NAME):$(IMAGE_TAG)
auth:
	@if [ -z "$(TOKEN)" ]; then \
		echo "TOKEN is empty"; \
		exit 1; \
	fi
	@echo $(TOKEN) | docker login ghcr.io -u $(USERNAME) --password-stdin
