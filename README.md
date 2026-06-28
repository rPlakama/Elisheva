# Elisheva

Personal NixOS flake managing multiple machines via a modular feature-based architecture within the porpuse of reducing hardcode;

## Hosts

| Host | Type | CPU | GPU | RAM | Storage | FS |
|---|---|---|---|---|---|---|
| **Centuria** | Desktop | Ryzen 7 5700X | RTX 3060 12GB | 32GB DDR4 | 512GB NVMe | XFS |
| **Moontier** | Server | i3-6100 | Intel HD 530 | 8GB DDR4 | 6TB + 1TB HDD | XFS |
| **Arthoplerau** | Laptop | Ryzen AI 350 | AMD Radeon | 16GB DDR5 | 512GB + 1TB NVMe | tmpfs + BTRFS |

## Structure

```
Hosts/           ← per-machine entry points (imports hardware.nix + Features)
Features/
├── Core/        ← always enabled: Central features -- being hardwre or services that are shared though multiple hosts.
├── Desktops/    ← graphical session: Everthing releated to a graphical environment.
├── Media/       ← self-hosted media, such as: Jellyfin...
└── Misc/        ← Non Specifc;
```

Each feature follows a simple pattern:

```nix
options.features.<name>.enable = lib.mkEnableOption "...";
config = lib.mkIf cfg.enable { ... };
```

Hosts enable features in their `default.nix`. Feature directories are auto-discovered — drop a `.nix` file into the right folder and it's automatically imported.

## Disko Installation

For hosts with `features.disko.enable = true`:

```bash
# From NixOS live ISO
mkdir nixos
git clone https://github.com/rPlakama/Elisheva.git ./nixos

# Partition the disk
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#<host> \
  --disk main /dev/nvme1n1 \
  --disk secondary /dev/nvme0n1  # for dual-drive hosts

nixos-install --flake .#<hostname>
```

For Centuria and Moontier (no disko), partition manually then run `nixos-install --flake .#<hostname>`.

## nixos-anywhere (remote install) (From Another NixOS Host) -- Preferably -- an more powerfull one.

```bash
# For hosts with disko, partitioning is handled automatically:
nix run github:nix-community/nixos-anywhere -- --flake .#<host> root@<ip>

# For hosts without disko, pre-partition the target then:
nix run github:nix-community/nixos-anywhere -- --flake .#<host> root@<ip>
```

## Tasks:

[] -- Find a better solution for Neovim
[] -- Improve homepage service integration, add options that can be called by other features, such as 'icon'

