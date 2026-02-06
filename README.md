# Just Keep Chasing

A wave-based 2D shooter with roguelite elements. Play as a nanobot fighting pathogens inside a human body.

[![GPL-3.0 license](https://img.shields.io/badge/license-GPL--3.0--only-blue)](LICENSE)

## The Pitch

Survive endless waves of viruses, bacteria, and parasites for 5 minutes to win. Collect "mito energy" to buy upgrades between waves. Auto-firing pico guns handle the shooting—you focus on positioning, weapon management, and power-up timing.

Built for quick sessions: one run takes 5-10 minutes. Good for coffee breaks.

## Features

- **Wave-based combat**: 30+ enemy types (Bact, Virus, Prion, Leech, Parasite, Tumor cells, Nerve impulses, Spores) with escalating difficulty
- **Weapon variety**: 10+ guns including pistols, shotguns (multiple types), sniper rifles, rocket launchers, and machine guns
- **Power-ups**: Heal, slow time, screen blast (clear nearby enemies), temporary invincibility
- **Augment system**: Purchase upgrades between waves (range enhancer, spreadlock, immuno-boosters, etc.)
- **Ally support**: WBC (White Blood Cell) companion assists in combat
- **30+ languages**: Full localization support including CJK
- **Cross-platform**: Windows, Linux, Android. Touch controls with virtual joysticks on mobile
- **Achievement system**: Track stats and unlocks with encrypted save data
- **Win condition**: Survive 300 seconds (5 minutes) to trigger victory screen

## Installation

### From Source (Godot 4 required)

```bash
git clone https://github.com/mlm-games/just-keep-chasing.git
cd just-keep-chasing
godot --editor  # Open in Godot editor
```

### Pre-built Binaries

**Linux:**
- [Flathub](https://flathub.org/apps/io.github.mlm_games.just-keep-chasing): `flatpak install flathub io.github.mlm_games.just-keep-chasing`
- [Snap Store](https://snapcraft.io/just-keep-chasing): `sudo snap install just-keep-chasing`
- Or download from [GitHub Releases](https://github.com/mlm-games/just-keep-chasing/releases)

**Windows:**
- Download from [GitHub Releases](https://github.com/mlm-games/just-keep-chasing/releases)
- Or via [itch.io](https://mlm-games.itch.io/just-keep-chasing)

**Android:**
- Download APK from [GitHub Releases](https://github.com/mlm-games/just-keep-chasing/releases)

## Quick Start

1. Launch the game
2. Click "Start Run" from main menu
3. Use WASD or arrow keys to move
4. Your gun auto-fires at nearest enemy
5. Press **Space** to switch weapons
6. Survive for 5 minutes to win

## Controls

| Key | Action |
|-----|--------|
| WASD / Arrows | Move |
| Space | Switch weapon |
| R | Reload current weapon |
| T | Throw weapon (discard) |
| E | Pick up nearby weapon |
| 1 | Slow Time power-up |
| 2 | Screen Blast power-up |
| 3 | Heal power-up |
| 4 | Invincibility power-up |
| Esc | Pause menu |

**Touch controls** (Android): Virtual joysticks for movement and aiming. Tap power-up buttons on HUD.

## Usage

### Weapon Management

Weapons have different characteristics:
- **Pistols**: Balanced, auto-fire
- **Shotguns**: Spread damage, shorter range
- **Snipers**: High damage, slow fire rate, piercing
- **Rocket launchers**: Area damage, ammo limited

Press **R** to reload. Some weapons need manual reload, others auto-reload when empty.

### Upgrades

Between waves, spend mito energy on augments:
- **Range Enhancer**: Increases weapon range
- **Spreadlock**: Reduces shotgun spread
- **Immuno-Boosters**: Health regeneration
- [Additional augments available in-game]

### Power-ups

Collect power-ups during combat:
- **Slow Time**: Enemies move at 50% speed for 10 seconds
- **Screen Blast**: Damages all nearby enemies
- **Heal**: Restores 50% health
- **Invincibility**: 5 seconds of immunity

## Why This Exists

Wanted to make an open-source rougelike that is similar to brotato (initially, has diverged), but didnt guage the difficulty then. Had to create most parts from scratch or forks, due to most libs not being aligned for my project, or extra complexity-inducing, for an already heavy project. 

Nanobot theme was due to, wanting to have an educational wordbase for items that helps you remember the medical terms, but not sticking to it, as there are too many exceptions for being able to easily replicate enemy types (would work if this was built like Thrive, but its not)

## Development Status

**Current version:** 0.8.13

**On hiatus** due to other tasks. The core gameplay loop is functional but:
- Artwork is placeholder (needs replacement)
- Some sound effects need replacement
- High score system, and unlockables not yet fully implemented

## Contributing

### Setup

1. Install [Godot 4](https://godotengine.org/)
2. Clone the repository
3. Open `project.godot` in Godot
4. Run the main scene (F5)

### Code Structure (for contributors)

```
scenes/
├── characters/      # Player, enemies, allies
├── components/      # Reusable components (health, velocity, hitbox)
├── gameplay/        # World scene, pickups, hazards
├── UI/             # Menus, HUD, upgrades
└── weapons-related/ # Guns, projectiles, inventory

resources/
├── guns/           # Weapon data files
├── enemies/        # Enemy type definitions
├── augments/       # Upgrade definitions
└── achievements/   # Achievement data

scripts/autoloads/  # Global singletons (game state, stats, etc.)
```

### Good First Issues

Might add issues labeled `good first issue` or `help wanted` later. Areas that need work:
- Art asset replacement
- Sound effect improvements
- Additional enemy types
- Balance tuning

See [CONTRIBUTING.md](CONTRIBUTING.md) if it exists, otherwise open an issue to discuss changes.

## Building

### Export Presets

Pre-configured export presets for:
- Windows Desktop
- Linux/X11
- Android

Export via Project → Export in Godot editor.

## Support

- **Issues:** [GitHub Issues](https://github.com/mlm-games/just-keep-chasing/issues)
- **Discussions:** [GitHub Discussions](https://github.com/mlm-games/just-keep-chasing/discussions)

## Acknowledgments

**Assets:**
- Gun sounds: [q009](https://opengameart.org/content/q009s-weapon-sounds), [Ben Jaszczak et al.](https://opengameart.org/content/the-free-firearm-sound-library)
- Bomb sprite: [Znevs](https://opengameart.org/content/bomb-sprite-vector-image)
- Fonts: Exo 2, Open Sans, Noto Sans SC (CJK support)

**Tools:**
- Built with [Godot Engine 4](https://godotengine.org/)

Full credits viewable in-game via the Credits button.

## License

GPL 3.0 only. See [LICENSE](LICENSE) file for details.

---

Star if you find that this eliminates your boredorm. Issues and PRs are welcome.
