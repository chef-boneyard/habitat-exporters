# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

pkg_name=hab-pkg-deb
pkg_origin=yzl
pkg_version=0.1.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source=nosuchfile.tar.gz
pkg_deps=(
  core/bash
  core/coreutils
  core/grep
  core/sed
  core/util-linux
  core/dpkg
    core/findutils
    core/hab
)
pkg_bin_dirs=(bin)
pkg_description="Exports a Debian package from a Habitat package."
pkg_upstream_url="https://github.com/chef/habitat-exporters"


# Callback Functions
#
# When defining your plan, you have the flexibility to override the default
# behavior of Habitat in each part of the package building stage through a
# series of callbacks. To define a callback, simply create a shell function
# of the same name in your plan.sh file and then write your script. If you do
# not want to use the default callback behavior, you must override the callback
# and return 0 in the function definition.
#
# Callbacks are defined here with either their "do_default_x", if they have a
# default implementation, or empty with "return 0" if they have no default
# implementation (Bash does not allow empty function bodies.) If callbacks do
# nothing or do the same as the default implementation, they can be removed from
# this template.
#
# The default implementations (the do_default_* functions) are defined in the
# plan build script:
# https://github.com/habitat-sh/habitat/tree/master/components/plan-build/bin/hab-plan-build.sh

do_download() {
  return 0 
}

do_verify() {
  return 0 
}

do_unpack() {
  return 0 
}

do_prepare() {
  return 0
}

do_build() {
  cp -v "$PLAN_CONTEXT/bin/$pkg_name.sh" "$pkg_name"

  sed \
    -e "s,#!/bin/bash$,#!$(pkg_path_for bash)/bin/bash," \
    -e "s,@author@,$pkg_maintainer,g" \
    -e "s,@version@,$pkg_version/$pkg_release,g" \
    -i $pkg_name
}

# The default implementation runs nothing during post-compile. An example of a
# command you might use in this callback is make test. To use this callback, two
# conditions must be true. A) do_check() function has been declared, B) DO_CHECK
# environment variable exists and set to true, env DO_CHECK=true.
do_check() {
  return 0
}

do_install() {
  install -v -D "$pkg_name" "$pkg_prefix/bin/$pkg_name"
}
