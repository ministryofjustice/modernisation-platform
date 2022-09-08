IMAGE := ministryofjustice/tech-docs-github-pages-publisher:v2

# Use this to run a local instance of the documentation site, while editing
# `make -f makefile` will run this container through docker
.PHONY: preview
preview:
	docker run --rm \
		-v $$(pwd)/config:/app/config \
		-v $$(pwd)/source:/app/source \
		-p 4567:4567 \
<<<<<<< HEAD
		-it $(IMAGE) /scripts/preview.sh
=======
		-it $(IMAGE) /scripts/preview.sh
>>>>>>> 7a8f5fc1d11360d8f8793be9f01852c24b4ca43e
