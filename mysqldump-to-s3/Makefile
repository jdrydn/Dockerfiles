VERSION=1.0.0

REGISTRY_DOCKER_PREFIX=jdrydn/mysqldump-to-s3
REGISTRY_ECR_PREFIX=public.ecr.aws/i1t9c1k5/mysqldump-to-s3
REGISTRY_GITHUB_PREFIX=ghcr.io/someimportantcompany/mysqldump-to-s3

# Build a test image - which will also check versions of installed packages
# $ make test
test:
	docker build -t ${REGISTRY_DOCKER_PREFIX}:test .

# Deploy the image - which will also check versions of installed packages under each architecture
# $ make deploy
deploy:
	docker buildx build --push \
		--platform linux/amd64,linux/arm64 \
		--file ./Dockerfile \
		--tag $(REGISTRY_DOCKER_PREFIX):$(VERSION) --tag $(REGISTRY_DOCKER_PREFIX):latest \
		--tag $(REGISTRY_ECR_PREFIX):$(VERSION) --tag $(REGISTRY_ECR_PREFIX):latest \
		--tag $(REGISTRY_GITHUB_PREFIX):$(VERSION) --tag $(REGISTRY_GITHUB_PREFIX):latest \
		.
