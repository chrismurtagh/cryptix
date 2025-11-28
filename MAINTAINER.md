# Maintainer Guide for Cryptix Overlay

This guide is for maintaining and developing the Cryptix Gentoo overlay.

## Repository Structure

```
cryptix/
├── README.md              # User-facing documentation
├── INSTALL.md            # Installation guide
├── MAINTAINER.md         # This file - maintainer documentation
├── metadata/
│   └── layout.conf       # Overlay configuration
├── profiles/
│   └── repo_name         # Repository identifier
└── app-editors/
    └── antigravity/
        ├── antigravity-VERSION.ebuild
        ├── metadata.xml
        ├── Manifest
        └── files/
            └── antigravity.desktop
```

## Ebuild Maintenance

### Adding a New Version

When Google releases a new version of Antigravity:

1. **Check the new download URL**:
   ```bash
   # Example new URL format
   # https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/NEW-VERSION/linux-x64/Antigravity.tar.gz
   ```

2. **Create new ebuild**:
   ```bash
   cd app-editors/antigravity
   cp antigravity-1.11.5.5234145629700096.ebuild antigravity-NEW_VERSION.ebuild
   ```

3. **Update the MY_PV variable** in the new ebuild:
   ```bash
   # Edit the file and change:
   MY_PV="1.11.5-5234145629700096"
   # to:
   MY_PV="NEW-VERSION-NUMBER"
   ```

4. **Generate the Manifest**:
   ```bash
   ebuild antigravity-NEW_VERSION.ebuild manifest
   ```

5. **Test the installation**:
   ```bash
   ebuild antigravity-NEW_VERSION.ebuild clean install
   # Check for errors

   sudo emerge --ask =app-editors/antigravity-NEW_VERSION
   # Test run
   antigravity --version
   ```

### Version Naming Convention

Antigravity's versioning is unusual:
- Download URL format: `1.11.5-5234145629700096` (dash separator)
- Gentoo PV format: `1.11.5.5234145629700096` (dot separator)

The ebuild uses `MY_PV` to bridge this difference.

### Updating Dependencies

Check for dependency changes:

1. **Extract the new tarball**:
   ```bash
   tar -tzf /var/cache/distfiles/antigravity-NEW_VERSION.tar.gz
   ```

2. **Check for library requirements**:
   ```bash
   ldd /tmp/Antigravity/antigravity
   ```

3. **Update RDEPEND** in the ebuild if needed

### Common Ebuild Variables

```bash
EAPI=8                    # Ebuild API version
MY_PV="..."              # Actual version in download URL
SRC_URI="..."            # Download location
LICENSE="MIT"            # Package license
SLOT="0"                 # Package slot
KEYWORDS="~amd64"        # Architecture support
RESTRICT="bindist..."    # Build restrictions
```

## Quality Assurance

### Pre-commit Checklist

Before committing changes:

- [ ] Ebuild passes `ebuild ... manifest` without errors
- [ ] Package installs successfully: `emerge --ask package`
- [ ] Application launches and runs: `antigravity --version`
- [ ] No QA warnings: Check `emerge` output
- [ ] metadata.xml validates: `xmllint --noout metadata.xml`
- [ ] Desktop file validates: `desktop-file-validate files/antigravity.desktop`

### Testing the Ebuild

```bash
# Full ebuild lifecycle test
cd /home/chrismurtagh/vcs/cryptix/app-editors/antigravity

# Clean any previous builds
ebuild antigravity-VERSION.ebuild clean

# Fetch source
ebuild antigravity-VERSION.ebuild fetch

# Unpack
ebuild antigravity-VERSION.ebuild unpack

# Prepare (apply patches, etc.)
ebuild antigravity-VERSION.ebuild prepare

# Install to temporary directory
ebuild antigravity-VERSION.ebuild install

# Create binary package
ebuild antigravity-VERSION.ebuild qmerge

# Full cycle
ebuild antigravity-VERSION.ebuild clean manifest install
```

### Validating Files

```bash
# Check metadata.xml
xmllint --noout --dtdvalid /usr/portage/metadata/dtd/metadata.dtd metadata.xml

# Check desktop file
desktop-file-validate files/antigravity.desktop

# Check ebuild
repoman manifest
repoman full
```

## Managing the Overlay

### Updating layout.conf

If you need to change overlay settings:

```bash
vim metadata/layout.conf
```

Important settings:
- `masters = gentoo` - Inherit from main Gentoo tree
- `thin-manifests = true` - Only track DIST entries
- `manifest-hashes = BLAKE2B SHA512` - Hash algorithms

### Adding New Packages

To add a completely new package (not just a new version):

1. **Create category directory** (if needed):
   ```bash
   mkdir -p category-name/package-name/files
   ```

2. **Create the ebuild**:
   ```bash
   touch category-name/package-name/package-name-VERSION.ebuild
   chmod 644 category-name/package-name/package-name-VERSION.ebuild
   ```

3. **Create metadata.xml**:
   ```bash
   vim category-name/package-name/metadata.xml
   ```

4. **Generate Manifest**:
   ```bash
   cd category-name/package-name
   ebuild package-name-VERSION.ebuild manifest
   ```

## Git Workflow

### Initial Repository Setup

```bash
cd /home/chrismurtagh/vcs/cryptix
git init
git add .
git commit -m "Initial commit: Cryptix overlay with Antigravity"
```

### Committing Changes

```bash
# Add modified files
git add app-editors/antigravity/

# Commit with descriptive message
git commit -m "app-editors/antigravity: version bump to X.Y.Z"

# Push to remote (if configured)
git push origin master
```

### Commit Message Format

Follow Gentoo conventions:

```
category/package: brief description

Detailed explanation if needed.

Bug: https://...
Signed-off-by: Your Name <your.email@example.com>
```

Examples:
```
app-editors/antigravity: version bump to 1.12.0.5234145629700096

Updated to latest stable release from Google.
```

```
app-editors/antigravity: fix desktop entry path

The icon path was incorrectly set. Updated to use the correct
path to the installed icon.
```

## Troubleshooting

### Manifest Generation Fails

```bash
# Common issue: download URL is wrong
# Check MY_PV matches the actual URL

# If URL changed format:
# Update SRC_URI in the ebuild
```

### QA Warnings

Common QA issues and fixes:

**QA Notice: Pre-stripped files**
```bash
# Add to ebuild:
RESTRICT="strip"
```

**QA Notice: Package has poor programming practices**
```bash
# For binary packages, add:
QA_PREBUILT="opt/${PN}/*"
```

**QA Notice: Desktop file has issues**
```bash
# Validate and fix:
desktop-file-validate files/antigravity.desktop
```

### Permission Issues

If files have wrong permissions after extraction:

```bash
# In src_prepare():
find . -type f -exec chmod 644 {} + || die
chmod 755 antigravity chrome-sandbox || die
```

## Overlay Distribution

### Publishing to GitHub

```bash
# Create GitHub repository
gh repo create cryptix --public --source=. --remote=origin

# Push overlay
git push -u origin master

# Update README.md with correct sync-uri
```

### Submitting to Gentoo (Optional)

To submit packages to official Gentoo:

1. Read [Contributing Guide](https://wiki.gentoo.org/wiki/Contributing_to_Gentoo)
2. Create bugzilla account
3. File a bug with ebuild attached
4. Respond to feedback from Gentoo developers

## Reference Files

### Example metadata.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
  <maintainer type="person">
    <email>your@email.com</email>
    <name>Your Name</name>
  </maintainer>
  <longdescription lang="en">
    Package description here.
  </longdescription>
  <use>
    <flag name="flagname">Flag description</flag>
  </use>
</pkgmetadata>
```

### Example Desktop Entry

```ini
[Desktop Entry]
Name=Application Name
Comment=Short description
Exec=/usr/bin/executable
Icon=icon-name
Type=Application
Categories=Category1;Category2;
```

## Resources

- [Gentoo Developer Manual](https://devmanual.gentoo.org/)
- [Ebuild Writing](https://devmanual.gentoo.org/ebuild-writing/)
- [Gentoo Metadata](https://devmanual.gentoo.org/ebuild-writing/misc-files/metadata/)
- [QA Policy](https://wiki.gentoo.org/wiki/Gentoo_Git_Workflow#Quality_assurance)
- [repoman Manual](https://dev.gentoo.org/~zmedico/portage/doc/man/repoman.1.html)
- [Gentoo Wiki - Custom Ebuild Repository](https://wiki.gentoo.org/wiki/Custom_ebuild_repository)
- [Portage Repository Format](https://wiki.gentoo.org/wiki/Repository_format)

## Contact

**Maintainer**: Chris Murtagh
**Email**: chris.murtagh1@gmail.com
**Repository**: chrismurtagh/cryptix



