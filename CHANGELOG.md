
## [0.8.13] - 2025-06-08

### Changed
- Performance improvements for Android
- Bullets now inherit from base_data for better code organization
- Reduced gun scan timer for more responsive shooting
- Added instance manager to handle spawns more efficiently

### Added
- Lighting effects for bullets
- Bullet speed dropoff over distance

### Removed
- Redundant #hacks comments
- base_shotgun files (consolidated into base gun system)

## [0.8.11] - 2025-05-20

### Changed
- Use proper export presets for all platforms
- Renamed "slime" enemy to "bact" for consistency with theme
- Pause game only when UI stack is empty (prevents accidental pauses)

### Added
- Stat tracking keys for achievements
- Simple visual improvement shader

## [0.8.10] - 2025-05-15

(No significant changes)

## [0.8.9] - 2025-05-10

### Changed
- Improved object pooling system
- Better saving of achievement progress
- Fixed stat updating logic
- Reduced code complexity in menu system

### Fixed
- Audio settings not persisting
- Unlock manager issues
- Explosion effects improved

### Added
- Initial unlocking system setup
- Stats tracking improvements

---

For older versions, see [GitHub releases](https://github.com/mlm-games/just-keep-chasing/releases).

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
