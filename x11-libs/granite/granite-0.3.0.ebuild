# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VALA_MIN_API_VERSION=0.24

inherit versionator gnome2-utils vala multilib cmake-utils

DESCRIPTION="A development library for elementary development"
HOMEPAGE="http://launchpad.net/granite"
SRC_URI="http://launchpad.net/${PN}/0.3/$(get_version_component_range 1-2)/+download/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="demo nls"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libgee:0.8[introspection]
	>=x11-libs/gtk+-3.11.6:3[introspection]"
DEPEND="${RDEPEND}
	$(vala_depend)
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

DOCS=( AUTHORS COPYING NEWS README )

src_prepare() {
	epatch_user

	# Disable building of the demo application (if needed)
	use demo || sed -i '/add_subdirectory (demo)/d' CMakeLists.txt

	# Disable generation of the translations (if needed)
	use nls || sed -i '/add_subdirectory (po)/d' CMakeLists.txt

	cmake-utils_src_prepare
	vala_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR=$(get_libdir)
		-DVALA_EXECUTABLE=${VALAC}
	)

	cmake-utils_src_configure
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
