# ABOUTME: Release automation targets for nix-install
# ABOUTME: Wraps version bumping, verification, tag creation, and hook install

.PHONY: bump-minor bump-patch verify-version release-tag install-hooks

bump-minor:
	./scripts/bump-version.sh minor

bump-patch:
	./scripts/bump-version.sh patch

verify-version:
	./scripts/verify-version.sh

install-hooks:
	./scripts/install-git-hooks.sh

release-tag:
	@set -eu; \
	branch="$$(git branch --show-current)"; \
	if [ "$$branch" != "main" ]; then \
		echo "release-tag failed: must run on main, currently on $${branch:-detached HEAD}" >&2; \
		exit 1; \
	fi; \
	if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$$(git ls-files --others --exclude-standard)" ]; then \
		echo "release-tag failed: working tree must be clean" >&2; \
		exit 1; \
	fi; \
	./scripts/verify-version.sh; \
	version="$$(tr -d '[:space:]' < VERSION)"; \
	tag="v$$version"; \
	if git rev-parse -q --verify "refs/tags/$$tag" >/dev/null; then \
		echo "release-tag failed: tag $$tag already exists" >&2; \
		exit 1; \
	fi; \
	git tag -a "$$tag" -m "$${RELEASE_TAG_MESSAGE:-Release $$tag}"; \
	echo "Created tag $$tag"; \
	echo "Push with:"; \
	echo "  git push origin main --tags"
