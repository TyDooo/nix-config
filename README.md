<h1 id="header" align="center">
    <img src=".github/assets/logo.png" width="200px" height="200px" />
    <br/>
    TyDooo's Nix Config
</h1>

![NixOS](https://img.shields.io/badge/NixOS-24.11-blue.svg)
![System Architecture](https://img.shields.io/badge/arch-x86__64--linux-lightgrey)

My personal NixOS and Home Manager configuration files. This repository contains
my complete system configuration, including development environment, desktop
setup, and application configurations.

## Features

- 🏠 Home Manager configuration for user environment
- 🔒 Secret management with [sops-nix](https://github.com/Mic92/sops-nix)
- 📝 [Neovim configuration](/parts/nvim/) using [nvf](https://github.com/NotAShelf/nvf)
- 💻 Multi-host configuration with shared modules
- 🔄 Automated system deployment with **nixos-anywhere**
- 💾 Disk partitioning and formatting with **disko**

## Configuring a new host

### Remotely using nixos-anywhere

A host can be configured remotely using nixos-anywhere and disko.

1. Pre-provision the SSH keys used by SOPS

```bash
# Create a temporary directory with the correct permissions
install -d -m755 "./tmp/persist/etc/ssh"

# Generate the desired SSH keys in the created directory
ssh-keygen -t ed25519 -f "./tmp/persist/etc/ssh/ssh_host_ed25519_key" -N "" -C "<USER>@<HOST>"
ssh-keygen -t rsa -b 4096 -f "./tmp/persist/etc/ssh/ssh_host_rsa_key" -N "" -C "<USER>@<HOST>"

# Ensure that the SSH keys have the appropriate permissions
chmod 600 ./tmp/persist/etc/ssh/*
```

2. Update the SOPS config (`.sops.yaml`) with the newly generated key

```bash
# Add the output of this command to the .sops.yaml file
cat ./tmp/persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

# Update the relevant secrets files with the new key
sops updatekeys PATH/TO/SECRETS.yml
```

3. Configure the host

```bash
nixos-anywhere --extra-files ./tmp --flake '.#<hostname>' <user>@<ip-address>
```

## Credits

This configuration is inspired by and borrows from:

- [NotAShelf/nyx](https://github.com/NotAShelf/nyx)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config/tree/main)
