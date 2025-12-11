# ABOUTME: User configuration template for Nix-Darwin MacBook setup
# ABOUTME: Placeholders are replaced during bootstrap to generate user-config.nix
{
  # Personal Information
  username = "@MACOS_USERNAME@";  # macOS login username
  fullName = "@FULL_NAME@";
  email = "@EMAIL@";
  notificationEmail = "@NOTIFICATION_EMAIL@";  # Email for maintenance notifications
  githubUsername = "@GITHUB_USERNAME@";
  hostname = "@HOSTNAME@";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Installation Profile
  installProfile = "@INSTALL_PROFILE@";  # "standard" or "power"

  # Mac App Store apps (requires App Store sign-in)
  # Set to true only if signed into App Store before running bootstrap
  enableMasApps = @ENABLE_MAS_APPS@;

  # Directory Configuration
  directories = {
    dotfiles = "@DOTFILES_PATH@";  # Nix configuration repository location
  };
}
