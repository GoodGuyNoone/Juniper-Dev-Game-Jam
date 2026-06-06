# Godot Game Jam Template

A Godot 4.6 project template for starting small games and game-jam projects with common runtime plumbing already wired together. It gives you a splash screen, main menu, pause menu, options menus, threaded scene loading, persistent settings, and a placeholder game scene that can be replaced with your own gameplay.

This template is based on Maaack's Game Template and adapted as a compact starting point for new Godot projects.

## Features

- Splash scene that fades into the main menu.
- Main menu with play, options, credits, and exit flows.
- Placeholder game scene with a pause menu controller attached.
- Pause menu with restart, options, main menu, and exit confirmations.
- Options menu tabs for input rebinding, audio, and video settings.
- Persistent player configuration saved through `user://player_config.cfg`.
- Basic global state storage saved through `user://global_state.tres`.
- Threaded scene loading with a loading screen.
- Credits window and scrollable credits scene.
- Default keyboard and gamepad input mappings for UI, movement, and interaction.

## Entry Points

- Main scene: `res://scenes/opening/splash.tscn`
- Main menu: `res://scenes/menus/main_menu/main_menu.tscn`
- Default game scene: `res://scenes/game_scene/game.tscn`
- Loading screen: `res://scenes/loading_screen/loading_screen.tscn`

The project uses two autoloads:

- `AppConfig` stores scene paths and applies saved settings at startup.
- `SceneLoader` loads scenes through Godot's threaded resource loading API.

To point the template at your game, update the exported scene paths in `autoloads/app_config/app_config.tscn` or set them from the Godot editor.

## Project Structure

- `autoloads/` - global app configuration and scene loading nodes.
- `scenes/opening/` - startup splash screen.
- `scenes/menus/main_menu/` - reusable main menu scene.
- `scenes/menus/options_menu/` - input, audio, and video options scenes.
- `scenes/windows/` - reusable overlay windows, pause menu, and menu windows.
- `scenes/loading_screen/` - base and project loading screen scenes.
- `scenes/credits/` - credits label and scrollable credits scene.
- `scenes/game_scene/` - placeholder game scene.
- `scripts/config/` - persistent settings helpers.
- `scripts/state/` - global state resource helpers.
- `scripts/labels/` - labels backed by project config or credits data.
- `scripts/menus/` - menu utility scripts.
- `scripts/utilities/` - input, focus, and pause-menu helpers.
- `resources/icons/` - icons used by the input remapping UI.
- `assets/` - project asset folder for your game content.

## Usage

Open `project.godot` in Godot 4.6, run the project, and replace `scenes/game_scene/game.tscn` with your game's first playable scene. Keep the pause menu controller on your gameplay scene if you want the default pause menu behavior.

Settings changed through the options menu are written to the user's data directory and reapplied automatically when the project starts.

## License

This project is distributed under the MIT license. See `LICENSE.txt`.