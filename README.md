# Cryptix Gentoo Overlay

A Gentoo portage overlay for custom and third-party packages.

## Overview

This overlay contains ebuilds for software not available in the official Gentoo repository or provides alternative versions of existing packages.

## Current Packages

### app-editors/antigravity

Google's Antigravity AI code IDE - an advanced code editor based on VSCode with integrated AI capabilities.

- **Version**: 1.11.9.4787439284912128
- **Homepage**: https://antigravity.google.com (hypothetical)
- **Description**: AI-powered code editor based on Visual Studio Code
- **License**: MIT (with bundled Chromium components)

### app-editors/cursor

Cursor is an AI-powered code editor built on top of Visual Studio Code with GPT-4 integration.

- **Versions**: 2.1.36.1764129366, 2.1.39
- **Homepage**: https://cursor.com
- **Description**: The AI Code Editor built on VSCode
- **License**: MIT

### sci-ml/lm-studio

LM Studio is a desktop application for discovering, downloading, and running large language models locally.

- **Version**: 0.3.32.2
- **Homepage**: https://lmstudio.ai
- **Description**: Discover, download, and run local LLMs privately and for free
- **License**: all-rights-reserved

### gui-apps/warp-terminal

Warp is a modern, AI-native terminal emulator built in Rust with integrated AI features and IDE-like editing.

- **Version**: 0.2025.11.19.08.12_p06
- **Homepage**: https://www.warp.dev
- **Description**: The AI-native terminal emulator built in Rust
- **License**: all-rights-reserved

## Installation

### Adding the Overlay Using eselect-repository

```bash
# If this is hosted on GitHub/GitLab
sudo eselect repository add cryptix git https://github.com/chrismurtagh/cryptix.git
sudo emerge --sync cryptix
```


## Package Details

### app-editors/antigravity

Antigravity is distributed as a pre-built binary package. The ebuild:

- Downloads the official tar.gz from Google's CDN
- Extracts to `/opt/antigravity`
- Installs a symlink to `/usr/bin/antigravity`
- Adds a desktop entry for application menus
- Handles all required dependencies for the Electron runtime

**System Requirements:**
- x86_64 architecture
- GTK+ 3.x
- Network Security Services (NSS)
- X11 libraries

### app-editors/cursor

Cursor is distributed as a pre-built binary package (repackaged from .deb). The ebuild:

- Downloads the official .deb package
- Extracts to `/opt/cursor`
- Installs a symlink to `/usr/bin/cursor`
- Adds a desktop entry for application menus
- Handles all required dependencies for the Electron/VSCode runtime
- Fixes permissions for bundled Node.js binaries to ensure AI features work

**System Requirements:**
- x86_64 architecture
- GTK+ 3.x
- Network Security Services (NSS)
- X11 libraries (libX11, libxcb, etc.)

### sci-ml/lm-studio

LM Studio is distributed as an AppImage which is extracted during installation. The ebuild:

- Downloads the official AppImage
- Extracts contents to `/opt/lm-studio`
- Installs a symlink to `/usr/bin/lm-studio`
- Adds a desktop entry for application menus
- Sets proper permissions for the chrome-sandbox and other executables

**System Requirements:**
- x86_64 architecture
- GTK+ 3.x
- FUSE (for AppImage compatibility)
- OpenGL support (mesa)
- X11 libraries

### gui-apps/warp-terminal

Warp Terminal is distributed as a pre-built binary package (repackaged from .deb). The ebuild:

- Downloads the official .deb package
- Extracts to `/opt/warp-terminal`
- Installs a symlink to `/usr/bin/warp-terminal`
- Adds a desktop entry for application menus
- Handles all required dependencies for the terminal runtime
- Sets proper permissions for all executables and libraries

**System Requirements:**
- x86_64 architecture
- GTK+ 3.x
- Network Security Services (NSS)
- X11 libraries (libX11, libxcb, etc.)
- Mesa (OpenGL support)

**Key Features:**
- AI-powered command suggestions and explanations
- Block-based UI for organized command output
- IDE-like editing with autocomplete
- Shared terminal sessions for collaboration
- Warp Drive for workflows and notebooks


## Maintainer

**Chris Murtagh**
- Email: chris.murtagh1@gmail.com

## License

Individual packages in this overlay may have different licenses. Check each package's metadata.xml and ebuild for specific licensing information.

This overlay infrastructure itself is provided as-is for personal use.

## Support

For issues with specific packages:

- **Antigravity**: Check Google's official support channels
- **Ebuild issues**: File an issue or submit a pull request
