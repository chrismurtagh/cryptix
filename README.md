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

## Installation

### Adding the Overlay Using eselect-repository

```bash
# If this is hosted on GitHub/GitLab
sudo eselect repository add cryptix git https://github.com/chrismurtagh/cryptix.git
sudo emerge --sync cryptix
```


## Package Details

### antigravity

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
