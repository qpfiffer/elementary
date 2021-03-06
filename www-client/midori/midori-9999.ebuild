# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/midori/midori-9999.ebuild,v 1.49 2013/06/01 14:27:45 ssuominen Exp $

EAPI=5
VALA_MIN_API_VERSION=0.20

PYTHON_COMPAT=( python2_7 )

inherit eutils fdo-mime gnome2-utils pax-utils python-any-r1 cmake-utils vala bzr

DESCRIPTION="A lightweight web browser based on WebKitGTK+"
HOMEPAGE="http://www.midori-browser.org/"
EBZR_REPO_URI="lp:midori"

LICENSE="LGPL-2.1 MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc +granite nls +jit +webkit2 zeitgeist"

RDEPEND=">=dev-db/sqlite-3.6.19:3
	>=dev-libs/glib-2.32.3
	dev-libs/libxml2
	>=net-libs/libsoup-2.38:2.4
	>=net-libs/libsoup-gnome-2.38:2.4
	>=x11-libs/libnotify-0.7
	x11-libs/libXScrnSaver
	>=app-crypt/gcr-3
	x11-libs/gtk+:3
	webkit2? ( >=net-libs/webkit-gtk-1.11.91:3[jit=] )
	!webkit2? ( >=net-libs/webkit-gtk-1.8.1:3[jit=] )
	granite? ( >=x11-libs/granite-0.2 )
	zeitgeist? ( >=dev-libs/libzeitgeist-0.3.14 )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	$(vala_depend)
	dev-util/intltool
	gnome-base/librsvg
	nls? ( sys-devel/gettext )
	doc? ( dev-util/gtk-doc )"


pkg_setup() {
	python-any-r1_pkg_setup

	DOCS=( AUTHORS ChangeLog HACKING README TODO TRANSLATE )
	HTML_DOCS=( data/faq.html data/faq.css )
}

src_prepare() {
	vala_src_prepare
	cmake-utils_src_prepare

	sed -i -e '/install/s:COPYING:HACKING TODO TRANSLATE:' CMakeLists.txt || die
	use nls || sed -i -e 's/add_subdirectory (po)//' CMakeLists.txt
}

src_configure() {
	strip-linguas -i po

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/${PF}
		$(cmake-utils_use_use doc APIDOCS)
		$(cmake-utils_use_use granite)
		$(cmake-utils_use_use zeitgeist)
		-DVALA_EXECUTABLE="${VALAC}"
		-DUSE_GTK3=ON
		$(cmake-utils_use webkit2 HALF_BRO_INCOM_WEBKIT2)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	local jit_is_enabled
	has_version 'net-libs/webkit-gtk:3[jit]' && jit_is_enabled=yes
	[[ ${jit_is_enabled} == yes ]] && pax-mark -m "${ED}"/usr/bin/${PN} #480290
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
