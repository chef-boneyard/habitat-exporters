pkg_name=hab-pkg-rpm
pkg_origin=chef
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source=nosuchfile.tar.gz
pkg_deps=(
  core/rpm
  core/bash
  core/coreutils
  core/grep
  core/sed
  core/util-linux
  core/findutils
  core/hab
  core/hab-studio
  core/handlebars-cmd
)
pkg_build_deps=(chef/inspec)
pkg_bin_dirs=(bin)
pkg_description="Exports an RPM package from a Habitat package."
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

# The default implementation is to update the prefix path for the configure
# script to use $pkg_prefix and then run make to compile the downloaded source.
# This means the script in the default implementation does
# ./configure --prefix=$pkg_prefix && make. You should override this behavior
# if you have additional configuration changes to make or other software to
# build and install as part of building your package.
do_build() {
  install -d "bin"
  install -v -D "$PLAN_CONTEXT/bin/$pkg_name.sh" bin/"$pkg_name"
  install -d "export/rpm"
  install -v -D -m 0644 "$PLAN_CONTEXT/export/rpm/spec" "export/rpm"

  sed \
    -e "s,#!/bin/bash$,#!$(pkg_path_for bash)/bin/bash," \
    -e "s,@author@,$pkg_maintainer,g" \
    -e "s,@version@,$pkg_version/$pkg_release,g" \
    -i "bin/$pkg_name"

}

# The default implementation runs nothing during post-compile. An example of a
# command you might use in this callback is make test. To use this callback, two
# conditions must be true. A) do_check() function has been declared, B) DO_CHECK
# environment variable exists and set to true, env DO_CHECK=true.
do_check() {
  "$PLAN_CONTEXT/tests/setup.sh" "$PWD" "$PLAN_CONTEXT"
  inspec exec "$PLAN_CONTEXT/tests/inspec"
}

# The default implementation is to run make install on the source files and
# place the compiled binaries or libraries in HAB_CACHE_SRC_PATH/$pkg_dirname,
# which resolves to a path like /hab/cache/src/packagename-version/. It uses
# this location because of do_build() using the --prefix option when calling the
# configure script. You should override this behavior if you need to perform
# custom installation steps, such as copying files from HAB_CACHE_SRC_PATH to
# specific directories in your package, or installing pre-built binaries into
# your package.
do_install() {
  install -d "$pkg_prefix/bin"
  install -v -D "./bin/$pkg_name" "$pkg_prefix/bin/$pkg_name"
  install -d "$pkg_prefix/export/rpm"
  install -v -D -m 0644 "./export/rpm/spec" "$pkg_prefix/export/rpm"
}
