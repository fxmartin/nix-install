# Quarantined bootstrap tests

The canonical test gate is `tests/run-safe-suite.sh`. It intentionally lists each
safe BATS suite instead of expanding `tests/*.bats`.

The following historical suites are quarantined because their mocks do not
reliably isolate the host. Several attempt writes under `/opt/homebrew`, depend on
readonly globals that they subsequently override, or assert behavior that no
longer matches the three-profile bootstrap flow:

- `08-final-darwin-rebuild.bats`
- `09-installation-summary.bats`
- `bootstrap_darwin_validation.bats`
- `bootstrap_github_key_upload.bats`
- `bootstrap_nix.bats`
- `bootstrap_nix_config.bats`
- `bootstrap_nix_darwin.bats`
- `bootstrap_profile_selection.bats`
- `bootstrap_repo_clone_test.bats`
- `bootstrap_ssh_key.bats`
- `bootstrap_ssh_test.bats`
- `bootstrap_user_config.bats`
- `bootstrap_user_prompts.bats`
- `bootstrap_xcode.bats`
- `issue-14-custom-clone-location.bats`

Do not add these suites to the required gate until each suite uses an isolated
temporary root, cannot call host package managers or rebuild commands, and its
expectations match current behavior. Run an individual quarantined test only in
a disposable environment.
