# ABOUTME: User configuration for Nix-Darwin MacBook setup
# ABOUTME: This file is OVERWRITTEN during bootstrap with your actual values
# ABOUTME: The template values below are placeholders only
{
  # Personal Information (replaced during bootstrap)
  username = "PLACEHOLDER";  # macOS login username
  fullName = "PLACEHOLDER";
  email = "PLACEHOLDER";
  notificationEmail = "PLACEHOLDER";  # Email for maintenance notifications
  githubUsername = "PLACEHOLDER";
  hostname = "PLACEHOLDER";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Installation Profile
  installProfile = "standard";  # "standard" or "power"

  # Mac App Store apps (requires App Store sign-in)
  enableMasApps = false;  # Set to true if signed into App Store

  # Directory Configuration
  directories = {
    dotfiles = ".config/nix-install";  # Nix configuration repository location
  };
}
