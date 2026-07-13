# ABOUTME: Non-secret user configuration used only for explicit CI flake evaluation
# ABOUTME: Production evaluation still requires the ignored user-config.nix file
{
  username = "runner";
  hostname = "ci-runner";
  email = "ci@example.invalid";
  fullName = "CI Runner";
  githubUsername = "ci-runner";
  notificationEmail = "ci@example.invalid";
  installProfile = "standard";
}
