# Escalating Fig Leaf

> Reworks the Dionysus Keepsake (Fig Leaf) to have an escalating chance to skip encounters.

## Features

- The chance to skip a non-essential encounter starts at the keepsake's default value (37%)
- The skip chance increases by 13% after every encounter you complete.
- The skip chance resets back to the default value when you enter a new biome.

## Installation

Install via [r2modman](https://thunderstore.io/c/hades-ii/) or manually place in your `ReturnOfModding/plugins` folder.

## Configuration

This mod has no configuration options besides enabling or disabling it.

## Development

This module is part of the [H2 Modular Modpack](https://github.com/h2-modpack/h2-modular-modpack). Please read the main project documentation for information on architecture and conventions.

- **[Project README](https://github.com/h2-modpack/h2-modular-modpack/blob/main/README.md)**: For local setup and prerequisites.
- **[Core CONTRIBUTING.md](https://github.com/h2-modpack/h2-modpack-Core/blob/main/CONTRIBUTING.md)**: For architecture, discovery system, and UI.
- **[Lib CONTRIBUTING.md](https://github.com/h2-modpack/h2-modpack-Lib/blob/main/CONTRIBUTING.md)**: For the public API reference, module contract, and shared utilities.

### Local Setup

1. Clone this repo
2. Run `Setup/init_repo.bat` (Windows) or `Setup/init_repo.sh` (Linux) to configure git hooks and branch protection
3. Run `Setup/deploy_local.bat` (Windows, as admin) or `Setup/deploy_local.sh` (Linux) to copy assets, generate manifest, and symlink into your r2modman profile