# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop unpacker wrapper xdg

# The download URL uses a dash between version components, but Gentoo uses dots
MY_PV="2.1.36-1764129366"

DESCRIPTION="The AI Code Editor built on VSCode"
HOMEPAGE="https://cursor.com"
SRC_URI="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.1 -> ${P}.deb"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"

RESTRICT="bindist mirror strip"

# Dependencies based on Electron requirements and VSCode needs
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-misc/curl
	net-print/cups
	sys-apps/util-linux
	x11-misc/xdg-utils
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
"

BDEPEND="
	>=dev-util/patchelf-0.9
"

QA_PREBUILT="opt/${PN}/*"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	default

	# Remove unused languages
	pushd usr/share/cursor/locales || die
	chromium_remove_language_paks
	popd || die

	# Fix permissions
	find usr/share/cursor -type f -exec chmod 644 {} + || die
	chmod 755 usr/share/cursor/cursor || die
	chmod 755 usr/share/cursor/chrome-sandbox || die
	chmod 755 usr/share/cursor/chrome_crashpad_handler || die
	chmod 755 usr/share/cursor/bin/cursor || die
	chmod 755 usr/share/cursor/libEGL.so || die
	chmod 755 usr/share/cursor/libffmpeg.so || die
	chmod 755 usr/share/cursor/libGLESv2.so || die
	chmod 755 usr/share/cursor/libvk_swiftshader.so || die
	chmod 755 usr/share/cursor/libvulkan.so.1 || die
}

src_install() {
	local install_dir="/opt/${PN}"

	# Install the main application
	insinto "${install_dir}"
	doins -r usr/share/cursor/.

	# Fix permissions for executables and libraries
	exeinto "${install_dir}"
	doexe usr/share/cursor/cursor
	doexe usr/share/cursor/chrome_crashpad_handler
	doexe usr/share/cursor/chrome-sandbox
	doexe usr/share/cursor/libEGL.so
	doexe usr/share/cursor/libffmpeg.so
	doexe usr/share/cursor/libGLESv2.so
	doexe usr/share/cursor/libvk_swiftshader.so
	doexe usr/share/cursor/libvulkan.so.1

	# Install wrapper script
	exeinto "${install_dir}/bin"
	doexe usr/share/cursor/bin/cursor

	# Create wrapper in /usr/bin
	make_wrapper cursor "${install_dir}/bin/cursor" "" "${install_dir}"

	# Install desktop entry
	domenu "${FILESDIR}/${PN}.desktop"

	# Install icons (extracted from resources if available)
	# Cursor typically bundles icons in resources/app/resources/linux/
	if [[ -f usr/share/cursor/resources/app/resources/linux/code.png ]]; then
		newicon -s 512 usr/share/cursor/resources/app/resources/linux/code.png ${PN}.png
	fi

	# Install bash completion if available
	if [[ -f usr/share/bash-completion/completions/cursor ]]; then
		insinto /usr/share/bash-completion/completions
		doins usr/share/bash-completion/completions/cursor
	fi

	# Install zsh completion if available
	if [[ -f usr/share/cursor/resources/completions/zsh/_cursor ]]; then
		insinto /usr/share/zsh/site-functions
		doins usr/share/cursor/resources/completions/zsh/_cursor
	fi

	# Fix directory permissions
	fperms 0755 "${install_dir}"
	fperms 0755 "${install_dir}/bin"
	fperms 0755 "${install_dir}/resources"

	# Create a symlink for chrome-sandbox with proper permissions
	fperms 4755 "${install_dir}/chrome-sandbox"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Cursor has been installed to ${EROOT}/opt/${PN}"
	elog ""
	elog "You can launch it by running 'cursor' or from your application menu."
	elog ""
	elog "If you encounter issues with GPU acceleration, you may need to:"
	elog "  - Install appropriate graphics drivers for your system"
	elog "  - Launch with: cursor --disable-gpu"
	elog ""
	elog "For CLI usage and remote development features, see:"
	elog "  cursor --help"
	elog ""
	if use wayland; then
		elog "Wayland support is experimental. If you experience issues,"
		elog "try running with: cursor --enable-features=UseOzonePlatform --ozone-platform=wayland"
	fi
	elog ""
	elog "Note: Running as root is not recommended. Use --user-data-dir if necessary."
}

pkg_postrm() {
	xdg_pkg_postrm
}
