# Update ROOT_DOCPATH to match your github pages site. By default, this will be
# /[repository name], e.g. for the repo ministryofjustice/technical-guidance
# this should be "/technical-guidance"

IMAGE := ministryofjustice/tech-docs-github-pages-publisher:0.5

# Use this to run a local instance of the documentation site, while editing
.PHONY: preview
preview:
	docker run --rm \
		-v $$(pwd)/config:/app/config \
		-v $$(pwd)/source:/app/source \
		-p 4567:4567 \
		-it $(IMAGE) /publishing-scripts/preview.sh
