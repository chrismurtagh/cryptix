# Cryptix Gentoo Overlay

A Gentoo portage overlay for AI and ML enabled packages.

## Overview

This overlay contains ebuilds for software not available in the official Gentoo repository or provides alternative versions of existing packages.

## Current Packages

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

## Maintainer

**Chris Murtagh**
- Email: chris.murtagh1@gmail.com

## License

Individual packages in this overlay may have different licenses. Check each package's metadata.xml and ebuild for specific licensing information.

This overlay infrastructure itself is provided as-is for personal use.

## Support

For issues with specific packages:

- **Ebuild issues**: File an issue or submit a pull request
