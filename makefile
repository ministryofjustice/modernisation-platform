# Update ROOT_DOCPATH to match your github pages site. By default, this will be
# /[repository name], e.g. for the repo ministryofjustice/technical-guidance
# this should be "/technical-guidance"

# You should never need to run this manually, because the github action should
# take care of publishing. see: .github/workflows/publish.yml
.PHONY: build
build:
	docker run --rm \
		-e ROOT_DOCPATH=$${ROOT_DOCPATH} \
		-v $$(pwd)/config.rb:/app/config.rb \
		-v $$(pwd)/config:/app/config \
		-v $$(pwd)/source:/app/source \
		-v $$(pwd)/docs:/app/docs \
		ministryofjustice/cloud-platform-tech-docs-publisher:1.1 \
		bundle exec middleman build --build-dir docs --relative-links
	touch docs/.nojekyll

# Use this to run a local instance of the documentation site, while editing
.PHONY: preview
preview:
	docker run --rm \
		-v $$(pwd)/config.rb:/app/config.rb \
		-v $$(pwd)/config:/app/config \
		-v $$(pwd)/source:/app/source \
		-p 4567:4567 \
		ministryofjustice/cloud-platform-tech-docs-publisher:1.1 \
		bundle exec middleman serve
