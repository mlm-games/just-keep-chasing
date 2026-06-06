## v0.8.20

- gunfire particles appear properly
- fix nerve_impulse err
- fix explosion anim
- fix nerve impulse and parasite art
- Cleanup common issues
- misc readme changes
- change the readme
- fix few reset glitches
- update short desc, and descs
- fix snap
- pause layer renaming
- fix few migr
- switch the the my-ecosystem-template's recent changes
- Actually go to the menuScreen, in win screen
- Win screen focus
- refactor, and add lifesteal proper hanlding, and other refactors
- upgrade project files for 4.6
- test 4.6-rc1
- Rename snapcraft.yml to snapcraft.yaml
- Rename star_powerup.svg to icon.svg
- Rename star_powerup.png to icon.png
- add icon to fastlane
- Create io.github.mlm_games.just-keep-chasing.desktop
- Create snap-upload.yml
- Create snapcraft.yml
- Delete scenes/digest.txt
- rem unused plugin (or very minor)
- rm unused extension
- rm temp files and add test utils
- Fix on screen powerup not working
- looks pretty well until you get to the upgrade screen
- remove a lot of get_tree requests by using a var, other template improvments, particles for currency_drop
- remove a lot of get_tree requests by using a var, other template improvments
- go bananas on screen shak, fix enemy flash -> brightness flash, other misc changes
- slight perf. improvement



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
