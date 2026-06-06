# Godot Game Jam Template

A lightweight Godot 4 template focused on reusable game-jam plumbing:

- Main menu
- Pause menu
- Basic options menu
- Input rebinding
- Audio settings
- Video settings
- Basic credits
- Splash/logo scene
- Threaded scene loading with loading screen
- Persistent player config
- Basic global state storage

The project starts at `res://scenes/opening/splash.tscn`.
The default game scene is `res://scenes/game_scene/game.tscn`.

## Kept Runtime Structure

- `scenes/menus/main_menu/` - root main menu wrapper.
- `scenes/opening/` - placeholder logo/splash scene before the main menu.
- `scenes/menus/options_menu/` - Controls, Audio, and Video tabs.
- `scenes/windows/` - pause menu and menu overlay windows.
- `scenes/loading_screen/` - loading screen wrapper.
- `scenes/credits/` - basic scrollable credits.
- `autoloads/` - app config and scene loader autoload scenes.
- `scripts/` - reusable config, state, label, menu, and utility scripts.
- `resources/` - small UI icons used by retained template controls.
- `assets/` - empty project asset folder for your game art/audio/data.
- `licenses/` - third-party license files for retained template code.

## Removed From the Original Template

The demo level progression, tutorials, level select, win/loss windows, end credits flow, shader-cache loading screen, microphone option, game reset option, example game state, translations, themes, input icon mapper, publishing helper scripts, and copied add-on examples were removed to keep this template neutral.
