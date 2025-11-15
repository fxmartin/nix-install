# ABOUTME: User configuration for Nix-Darwin MacBook setup (VM testing)
# ABOUTME: This is a test configuration for the VM environment
{
  # Personal Information
  username = "fxmartin";  # macOS login username
  fullName = "François-Xavier Martin";
  email = "mail@fxmartin.me";
  githubUsername = "fxmartin";
  hostname = "fxmartins-MacBook-Pro";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Installation Profile
  installProfile = "power";  # "standard" or "power"

  # Directory Configuration
  directories = {
    dotfiles = "Documents/nix-install";  # Nix configuration repository location
  };
}
