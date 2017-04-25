pkg_name=hab-pkg-deb
pkg_origin=chef
pkg_version=0.1.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source=nosuchfile.tar.gz
# dpkg-deb depends on GNU tar, which is installed as a dependency of core/hab.
pkg_deps=(
  core/bash
  core/coreutils
  core/grep
  core/sed
  core/util-linux
  core/dpkg
  core/findutils
  core/hab
  core/hab-studio
  core/handlebars-cmd
)
pkg_build_deps=(chef/inspec)
pkg_bin_dirs=(bin)
pkg_description="Exports a Debian package from a Habitat package."
pkg_upstream_url="https://github.com/chef/habitat-exporters"

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_build() {
  install -d "bin"
  install -v -D "$PLAN_CONTEXT/bin/$pkg_name.sh" bin/"$pkg_name"
  install -d "export/deb"
  install -v -D -m 0644 "$PLAN_CONTEXT/export/deb/control" "export/deb"

  sed \
    -e "s,#!/bin/bash$,#!$(pkg_path_for bash)/bin/bash," \
    -e "s,@author@,$pkg_maintainer,g" \
    -e "s,@version@,$pkg_version/$pkg_release,g" \
    -i "bin/$pkg_name"
}

do_check() {
  "$PLAN_CONTEXT/tests/setup.sh" "$PWD" "$PLAN_CONTEXT"
  hab pkg exec chef/inspec inspec exec "$PLAN_CONTEXT/tests/inspec"
}

do_install() {
  install -d "$pkg_prefix/bin"
  install -v -D "./bin/$pkg_name" "$pkg_prefix/bin/$pkg_name"
  install -d "$pkg_prefix/export/deb"
  install -v -D -m 0644 "./export/deb/control" "$pkg_prefix/export/deb"
}
