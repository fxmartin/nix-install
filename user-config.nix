# ABOUTME: User configuration for Nix-Darwin MacBook setup
# ABOUTME: This file is OVERWRITTEN during bootstrap with your actual values
# ABOUTME: The template values below are placeholders only
{
  # Personal Information (replaced during bootstrap)
  username = "fxmartin";  # macOS login username
  fullName = "François-Xavier Martin";
  email = "mail@fxmartin.me";
  notificationEmail = "notifications@fxmartin.me";  # Email for maintenance notifications
  githubUsername = "fxmartin";
  hostname = "fxmartins-MacBook-Pro";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Installation Profile
  installProfile = "power";  # "standard" or "power"

  # Mac App Store apps (requires App Store sign-in)
  enableMasApps = false;  # Set to true if signed into App Store

  # Directory Configuration
  directories = {
    dotfiles = "Documents/nix-install";  # Nix configuration repository location (MacBook Pro uses Documents/)
  };
}
