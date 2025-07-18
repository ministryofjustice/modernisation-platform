.PHONY: package preview

.DEFAULT_GOAL := preview

TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE     ?= ghcr.io/ministryofjustice/tech-docs-github-pages-publisher
TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE_SHA ?= sha256:c55eb7a18eb667a2e616e16cf0918b26c1932fc03e6ad8e9bfe6961fd746692e # v6.0.1

package:
	docker run --rm \
	    --name tech-docs-github-pages-publisher \
	    --volume $(PWD)/config:/tech-docs-github-pages-publisher/config \
		--volume $(PWD)/source:/tech-docs-github-pages-publisher/source \
		$(TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE)@$(TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE_SHA) \
		/usr/local/bin/package

preview:
	docker run -it --rm \
	    --name tech-docs-github-pages-publisher-preview \
	    --volume $(PWD)/config:/tech-docs-github-pages-publisher/config \
		--volume $(PWD)/source:/tech-docs-github-pages-publisher/source \
		--publish 4567:4567 \
		$(TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE)@$(TECH_DOCS_GITHUB_PAGES_PUBLISHER_IMAGE_SHA) \
		/usr/local/bin/preview

link-check:
	lyche --verbose --no-progress './**/*.md' './**/*.html' './**/*.erb' --config config/lychee.toml
