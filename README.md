# Elisheva

Personal NixOS flake managing multiple machines with a modular, feature-based architecture (each feature is opt-in via an `enable` flag to avoid hardcoding).

## Hosts

| Host | Type | GPU | Storage |
|---|---|---|---|
| **Centuria** | Desktop | RTX 3060 12GB | 512GB NVMe |
| **Moontier** | Server | AMD Radeon | 6TB |
| **Arthoplerau** | Laptop | AMD Radeon | 512GB + 1TB NVMe (dual) |

## Structure

```
Hosts/           per-machine entry point (imports hardware.nix + Features)
Features/
├── Core/        always enabled: hardware & services shared across hosts
├── Desktops/    graphical sessions
├── Media/       self-hosted media (Jellyfin, etc.)
└── Misc/        everything else
```

Feature dirs are **auto-imported** — drop any `.nix` file into a folder and it's picked up. Hosts enable features in `Hosts/<name>/default.nix`; each feature exposes `options.features.<name>.enable` gated by `config = mkIf cfg.enable`.

## Impermanence & the fast tier

With `features.preservation`, `/` is tmpfs and **only what's declared survives a reboot**. Persistent mounts: `/nix`, `/fast`, `/persistent`, `/boot`.

Placement is decided by the mount point:

- **Primary (fast) drive** → `/nix`, plus `/fast` holding *all system state* (`features.preservation.system.*`) and an *optional fast home* subset (`features.preservation.fast.home.directories`, default `Projects`, `.cache`).
- **Secondary drive** → `/persistent` with the rest of home (`features.preservation.home.*`).
- **One-drive hosts** — no fast tier; everything falls back to `/persistent`.

`/fast` exists only when `features.disko.dualDrive.enable` + `.fastDirs`.

## Modules cross-talk

<img src="images/modules-cross-talk.png" alt="Just a reference, not kept up-to-date" width="1000">