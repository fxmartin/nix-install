# ABOUTME: Release automation targets for nix-install
# ABOUTME: Wraps version bumping, verification, tag creation, and hook install

.PHONY: bump-major bump-minor bump-patch release-major release-minor release-patch verify-version fmt-check shellcheck test security-scan check-generated nix-eval check release-tag install-hooks

bump-major:
	./scripts/bump-version.sh major "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

bump-minor:
	./scripts/bump-version.sh minor "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

bump-patch:
	./scripts/bump-version.sh patch "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

release-major:
	./scripts/release.sh major "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

release-minor:
	./scripts/release.sh minor "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

release-patch:
	./scripts/release.sh patch "$${RELEASE_NOTE:?set RELEASE_NOTE='release summary'}"

verify-version:
	./scripts/verify-version.sh

fmt-check:
	git ls-files -z '*.nix' ':!:user-config.nix' ':!:user-config.template.nix' | xargs -0 nixfmt --check

shellcheck:
	shellcheck --severity=warning bootstrap.sh lib/*.sh scripts/*.sh tests/*.sh

test:
	./tests/run-safe-suite.sh

security-scan:
	gitleaks git . --config .gitleaks.toml --no-banner

check-generated:
	./scripts/check-generated.sh

nix-eval:
	NIX_INSTALL_CI=1 nix flake show --impure >/dev/null
	@for profile in standard power ai-assistant; do \
		echo "Evaluating $$profile system derivation"; \
		NIX_INSTALL_CI=1 nix eval --impure --raw "path:.#darwinConfigurations.$$profile.system.drvPath" >/dev/null; \
	done
	git diff --exit-code -- flake.lock

check: fmt-check shellcheck test security-scan check-generated verify-version nix-eval

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
	git tag -s "$$tag" -m "$${RELEASE_TAG_MESSAGE:-Release $$tag}"; \
	echo "Created tag $$tag"; \
	echo "Push with:"; \
	echo "  git push origin main --tags"
