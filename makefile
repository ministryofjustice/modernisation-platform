IMAGE := ministryofjustice/tech-docs-github-pages-publisher:v3.0.1

# Use this to run a local instance of the documentation site, while editing
# `make -f makefile` will run this container through docker
.PHONY: preview
preview:
	docker run --rm --platform linux/amd64 \
		-v $$(pwd)/config:/app/config \
		-v $$(pwd)/source:/app/source \
		-p 4567:4567 \
		-it $(IMAGE) /scripts/preview.sh
