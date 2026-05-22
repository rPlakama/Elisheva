
- **Elisheva**: Ryzen 7 5700U | 32GB RAM DDR4 | 1TB NVME - XFS
- **Centuria (Desktop)**: Ryzen 7 5700X | 32GB RAM DDR4 | 512GB NVME - XFS | (Desktop) Discrete GPU, RTX 3060 12GB GDDR6
- **Moontier (Server)**: i3 6100 | 8GB DDR4 | 6TB HDD + 1TB HDD - XFS
- **Arthoplerau** (Laptop) Ryzen AI 350 | 2*8 DDR5 | 512GB

--> This configuration follows the feature style of configuration, which:

Flake <-- Creates hosts receving their ```hardwares/defaults.nix``` from ```/Hosts/``` \

Features <-- Contains a default.nix which create imports from dir inside of it; The feature follow this structure:

```Feature/Feature/default.nix``` Which default.nix is a entry point for whatever the feature needs.

What happens after is it create an option which can be enabled by a Host, per example:

```
  options.optionals.features.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Neovim Configuration";
    default = true;
  };

```

