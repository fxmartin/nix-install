# ABOUTME: User configuration template for Nix-Darwin MacBook setup
# ABOUTME: Placeholders are replaced during bootstrap to generate user-config.nix
{
  # Personal Information
  username = "@MACOS_USERNAME@";  # macOS login username
  fullName = "@FULL_NAME@";
  email = "@EMAIL@";
  githubUsername = "@GITHUB_USERNAME@";
  hostname = "@HOSTNAME@";  # Only letters, numbers, and hyphens
  signingKey = "";  # GPG key ID (leave empty initially)

  # Directory Configuration
  directories = {
    dotfiles = "@DOTFILES_PATH@";  # Nix configuration repository location
  };
}
