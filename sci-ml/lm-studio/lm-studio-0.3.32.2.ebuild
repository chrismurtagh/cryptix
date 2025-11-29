# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper xdg

# The download URL uses a dash between version components, but Gentoo uses dots
MY_PV="0.3.32-2"

DESCRIPTION="Discover, download, and run local LLMs privately and for free"
HOMEPAGE="https://lmstudio.ai"
SRC_URI="https://installers.lmstudio.ai/linux/x64/${MY_PV}/LM-Studio-${MY_PV}-x64.AppImage -> ${P}.AppImage"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"

RESTRICT="bindist mirror strip"

# AppImage dependencies
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
	sys-fs/fuse:0
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
	sys-fs/squashfs-tools
"

QA_PREBUILT="opt/${PN}/*"

S="${WORKDIR}"

src_unpack() {
	# Extract AppImage
	cp "${DISTDIR}/${A}" "${S}/${PN}.AppImage" || die
	chmod +x "${S}/${PN}.AppImage" || die
	"${S}/${PN}.AppImage" --appimage-extract || die "Failed to extract AppImage"

	# The extraction creates a squashfs-root directory
	mv squashfs-root "${PN}" || die
}

src_prepare() {
	default

	cd "${PN}" || die

	# Fix permissions
	find . -type f -exec chmod 644 {} + || die

	# Mark executables
	if [[ -f lm-studio ]]; then
		chmod 755 lm-studio || die
	fi
	if [[ -f LM-Studio ]]; then
		chmod 755 LM-Studio || die
	fi
	if [[ -f chrome-sandbox ]]; then
		chmod 755 chrome-sandbox || die
	fi
	if [[ -f chrome_crashpad_handler ]]; then
		chmod 755 chrome_crashpad_handler || die
	fi

	# Mark libraries and bundled utilities as executable
	find . -name "*.so*" -type f -exec chmod 755 {} + || die
	find resources/app/.webpack/bin -type f -exec chmod 755 {} + 2>/dev/null || true
}

src_install() {
	local install_dir="/opt/${PN}"

	# Install the main application
	insinto "${install_dir}"
	doins -r "${PN}"/.

	# Fix permissions for main executable
	if [[ -f "${PN}"/lm-studio ]]; then
		fperms 0755 "${install_dir}/lm-studio"
	fi
	if [[ -f "${PN}"/LM-Studio ]]; then
		fperms 0755 "${install_dir}/LM-Studio"
	fi
	if [[ -f "${PN}"/chrome-sandbox ]]; then
		fperms 4755 "${install_dir}/chrome-sandbox"
	fi
	if [[ -f "${PN}"/chrome_crashpad_handler ]]; then
		fperms 0755 "${install_dir}/chrome_crashpad_handler"
	fi

	# Fix library permissions
	find "${D}${install_dir}" -name "*.so*" -type f -exec chmod 755 {} + || die

	# Fix bundled utilities permissions
	if [[ -d "${D}${install_dir}/resources/app/.webpack/bin" ]]; then
		find "${D}${install_dir}/resources/app/.webpack/bin" -type f -exec chmod 755 {} + || die
	fi

	# Create wrapper in /usr/bin
	# Find the actual executable name
	local exe_name
	if [[ -f "${PN}"/lm-studio ]]; then
		exe_name="lm-studio"
	elif [[ -f "${PN}"/LM-Studio ]]; then
		exe_name="LM-Studio"
	else
		die "Cannot find LM Studio executable"
	fi

	make_wrapper lm-studio "${install_dir}/${exe_name}" "" "${install_dir}"

	# Install desktop entry
	domenu "${FILESDIR}/${PN}.desktop"

	# Install icon if available
	if [[ -f "${PN}"/lm-studio.png ]]; then
		newicon -s 512 "${PN}"/lm-studio.png ${PN}.png
	elif [[ -f "${PN}"/usr/share/icons/hicolor/512x512/apps/lm-studio.png ]]; then
		newicon -s 512 "${PN}"/usr/share/icons/hicolor/512x512/apps/lm-studio.png ${PN}.png
	fi

	# Fix directory permissions
	fperms 0755 "${install_dir}"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LM Studio has been installed to ${EROOT}/opt/${PN}"
	elog ""
	elog "You can launch it by running 'lm-studio' or from your application menu."
	elog ""
	elog "LM Studio allows you to run large language models locally on your computer."
	elog "Models will be downloaded to your user directory on first use."
	elog ""
	elog "If you encounter issues with GPU acceleration, you may need to:"
	elog "  - Install appropriate graphics drivers for your system"
	elog "  - Ensure CUDA/ROCm is properly configured for GPU acceleration"
	elog ""
	if use wayland; then
		elog "Wayland support is experimental. If you experience issues,"
		elog "try running in X11 mode or with XWayland."
	fi
	elog ""
	elog "For more information, visit: https://lmstudio.ai/docs"
}

pkg_postrm() {
	xdg_pkg_postrm
}
