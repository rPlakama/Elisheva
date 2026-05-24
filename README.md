### Hosts
- **Elisheva**: Ryzen 7 5700U | 32GB RAM DDR4 | 1TB NVME - XFS
- **Centuria (Desktop)**: Ryzen 7 5700X | 32GB RAM DDR4 | 512GB NVME - XFS | (Desktop) Discrete GPU, RTX 3060 12GB GDDR6
- **Moontier (Server)**: i3 6100 | 8GB DDR4 | 6TB HDD + 1TB HDD - XFS
- **Arthoplerau** (Laptop) Ryzen AI 350 | 2*8 DDR5 | 512GB + 1TB NVME | BTRFS (Yet to arrival)

### Features?
--> This configuration follows the feature style of configuration, which:

Flake <-- Creates hosts receving their ```hardwares/defaults.nix``` from ```/Hosts/``` \

Features <-- Contains a default.nix which create imports from dir inside of it; The feature follow this structure:

```Feature/Feature/default.nix``` Which default.nix is a entry point for whatever the feature needs.

What happens after is it create an option which can be enabled by a Host, per example:

```
  options.features.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Neovim Configuration";
    default = true;
  };

```

### Disko Installation

For hosts with `features.disko.enable = true`:

```bash
# From NixOS live ISO, clone the flake:
git clone https://github.com/rPlakama/Elisheva.git /mnt/etc/nixos

# Partition the disk according to the host's disko config:
nix run github:nix-community/disko -- --mode disko --flake /mnt/etc/nixos#<hostname>

# Then install:
nixos-install --flake /mnt/etc/nixos#<hostname>
```

### Disko & Preservation Options

Available under `features` in any host config:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `disko.enable` | bool | `false` | Enable disko partitioning |
| `disko.dualDrive` | bool | `false` | Split `/persist` + `/home` onto secondary drive |
| `disko.primaryDrive` | str | `""` | Primary (fastest) drive, e.g. `/dev/nvme0n1` |
| `disko.secondaryDrive` | str | `""` | Secondary (slower) drive, e.g. `/dev/nvme1n1` |
| `disko.isSSD` | bool | `true` | Enables `discard=async` + `ssd` mount options |
| `preservation.enable` | bool | `disko.enable` | Enable persistent state (impermanence) |
| `preservation.additionalHomeDirs` | list | `[]` | Extra home dirs to persist, e.g. `[".config/vesktop"]` |
| `preservation.additionalDirs` | list | `[]` | Extra system dirs to persist, e.g. `["/var/lib/docker"]` |
| `preservation.additionalFiles` | list | `[]` | Extra system files to persist, e.g. `["/etc/adjtime"]` |

**Default persisted directories:**
- System: `/etc/nixos`, `/var/lib/tailscale`, `/var/lib/bluetooth`, `/var/lib/nixos`, `/var/log`, `/etc/NetworkManager/system-connections`, `/etc/ssh`
- System files: `/etc/machine-id`
- User: `Downloads`, `Projects`, `Pictures`, `Documents`, `Videos`, `.local/share`, `.local/state`, `.ssh`
