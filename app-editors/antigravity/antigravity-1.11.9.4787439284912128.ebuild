# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop wrapper xdg

# The download URL uses a dash between version components, but Gentoo uses dots
MY_PV="1.11.9-4787439284912128"

DESCRIPTION="Google's Antigravity AI code IDE based on Visual Studio Code"
HOMEPAGE="https://antigravity.google.com"
SRC_URI="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/${PN}/stable/${MY_PV}/linux-x64/Antigravity.tar.gz -> ${P}.tar.gz"

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
	net-print/cups
	sys-apps/util-linux
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

S="${WORKDIR}/Antigravity"

src_prepare() {
	default

	# Remove unused languages
	pushd locales || die
	chromium_remove_language_paks
	popd || die

	# Fix permissions
	find . -type f -exec chmod 644 {} + || die
	chmod 755 antigravity chrome-sandbox chrome_crashpad_handler || die
	chmod 755 bin/antigravity || die
	chmod 755 libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1 || die

	# Mark bundled Node.js binaries, native modules, and extension binaries as executable
	# This is critical for AI agent functionality (ripgrep, pty, language server, etc.)
	find resources/app/node_modules -type f \( -path "*/bin/*" -o -name "*.node" \) -exec chmod 755 {} + || true
	find resources/app/extensions -type f -path "*/bin/*" -exec chmod 755 {} + || true
}

src_install() {
	local install_dir="/opt/${PN}"

	# Install the main application
	insinto "${install_dir}"
	doins -r .

	# Fix permissions for executables and libraries
	exeinto "${install_dir}"
	doexe antigravity chrome_crashpad_handler chrome-sandbox
	doexe libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1

	# Ensure all Node.js native binaries and extension binaries remain executable in installed location
	# Without this, the AI agent cannot spawn ripgrep, use native modules, or start the language server
	find "${D}${install_dir}/resources/app/node_modules" -type f \( -path "*/bin/*" -o -name "*.node" \) -exec chmod 755 {} + || die
	find "${D}${install_dir}/resources/app/extensions" -type f -path "*/bin/*" -exec chmod 755 {} + || die

	# Install wrapper script
	exeinto "${install_dir}/bin"
	doexe bin/antigravity

	# Create wrapper in /usr/bin
	make_wrapper antigravity "${install_dir}/bin/antigravity" "" "${install_dir}"

	# Install desktop entry
	domenu "${FILESDIR}/${PN}.desktop"

	# Install icons (extracted from resources if available)
	# Antigravity typically bundles icons in resources/app/resources/linux/
	if [[ -f resources/app/resources/linux/code.png ]]; then
		newicon -s 512 resources/app/resources/linux/code.png ${PN}.png
	fi

	# Install bash completion if available
	if [[ -f resources/completions/bash/antigravity ]]; then
		insinto /usr/share/bash-completion/completions
		doins resources/completions/bash/antigravity
	fi

	# Install zsh completion if available
	if [[ -f resources/completions/zsh/_antigravity ]]; then
		insinto /usr/share/zsh/site-functions
		doins resources/completions/zsh/_antigravity
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

	elog "Antigravity has been installed to ${EROOT}/opt/${PN}"
	elog ""
	elog "You can launch it by running 'antigravity' or from your application menu."
	elog ""
	elog "If you encounter issues with GPU acceleration, you may need to:"
	elog "  - Install appropriate graphics drivers for your system"
	elog "  - Launch with: antigravity --disable-gpu"
	elog ""
	elog "For CLI usage and remote development features, see:"
	elog "  antigravity --help"
	elog ""
	if use wayland; then
		elog "Wayland support is experimental. If you experience issues,"
		elog "try running with: antigravity --enable-features=UseOzonePlatform --ozone-platform=wayland"
	fi
	elog ""
	elog "Note: Running as root is not recommended. Use --user-data-dir if necessary."
}

pkg_postrm() {
	xdg_pkg_postrm
}
