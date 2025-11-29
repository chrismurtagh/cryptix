# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop unpacker wrapper xdg

DESCRIPTION="The AI-native terminal emulator built in Rust"
HOMEPAGE="https://www.warp.dev"
SRC_URI="https://releases.warp.dev/stable/v0.2025.11.19.08.12.stable_06/warp-terminal_0.2025.11.19.08.12.stable.06_amd64.deb -> ${P}.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"

RESTRICT="bindist mirror strip"

# Dependencies based on Electron/terminal requirements
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
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

	# The .deb has a very simple structure with just the warp binary
	# Fix permissions
	if [[ -f opt/warpdotdev/warp-terminal/warp ]]; then
		chmod 755 opt/warpdotdev/warp-terminal/warp || die
	fi
}

src_install() {
	local install_dir="/opt/${PN}"

	# Install the main warp binary
	exeinto "${install_dir}"
	doexe opt/warpdotdev/warp-terminal/warp

	# Create wrapper in /usr/bin
	make_wrapper warp-terminal "${install_dir}/warp" "" "${install_dir}"

	# Install the desktop file from the .deb if it exists
	if [[ -f usr/share/applications/dev.warp.Warp.desktop ]]; then
		domenu usr/share/applications/dev.warp.Warp.desktop
	else
		# Otherwise use our custom one
		domenu "${FILESDIR}/${PN}.desktop"
	fi

	# Install icons if available
	if [[ -d usr/share/icons/hicolor ]]; then
		insinto /usr/share/icons/hicolor
		doins -r usr/share/icons/hicolor/*
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Warp Terminal has been installed to ${EROOT}/opt/${PN}"
	elog ""
	elog "You can launch it by running 'warp-terminal' or from your application menu."
	elog ""
	elog "Warp is a modern terminal emulator with AI-powered features including:"
	elog "  - AI command suggestions and explanations"
	elog "  - Block-based UI for better output organization"
	elog "  - IDE-like editing with autocomplete"
	elog "  - Shared sessions for collaboration"
	elog "  - Warp Drive for workflows and notebooks"
	elog ""
	elog "If you encounter issues with GPU acceleration, you may need to:"
	elog "  - Install appropriate graphics drivers for your system"
	elog "  - Launch with: warp-terminal --disable-gpu"
	elog ""
	if use wayland; then
		elog "Wayland support is experimental. If you experience issues,"
		elog "try running with X11/XWayland instead."
	fi
	elog ""
	elog "Note: Warp requires account creation for cloud features like Warp Drive."
	elog "Visit https://www.warp.dev for more information."
}

pkg_postrm() {
	xdg_pkg_postrm
}
