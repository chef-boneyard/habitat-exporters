#!/bin/bash

build_dir="$1"
test_dir="$2/tests"

hab pkg install core/busybox
busybox_pkg_dir=$(hab pkg path core/busybox)
hab pkg install core/netcat

echo 'Test setup noopts: build package with no option overrides'
"$build_dir/bin/hab-pkg-rpm" --testname noopts core/busybox

echo 'Test setup dist_tag: provide dist_tag via CLI'
"$build_dir/bin/hab-pkg-rpm" --testname dist_tag --dist_tag el7 core/netcat

echo 'Test setup for pkg_provides_description: package provides a description in its plan.sh'
"$build_dir/bin/hab-pkg-rpm" --testname pkg_provides_description core/netcat

echo 'Test setup for cli_provides_section: provide group via CLI'
"$build_dir/bin/hab-pkg-rpm" --testname cli_provides_group --group somegroup core/netcat

echo 'Test setup for pkg_provides_upstream_url: package provides an upstream url in its plan.sh'
"$build_dir/bin/hab-pkg-rpm" --testname pkg_provides_upstream_url core/netcat

echo 'Test setup for cli_provides_compression: provide compression type via CLI'
"$build_dir/bin/hab-pkg-rpm" --testname cli_provides_compression --compression xz core/netcat

<<COMMENT
echo 'Test setup for pkg_provides_install_scripts: package provides its own install scripts'
for script in postinst postrm preinst prerm; do
  install "$test_dir/inputs/1/$script" "$busybox_pkg_dir/bin"
  "$build_dir/bin/hab-pkg-deb" --testname "pkg_provides_$script" core/busybox
  # Cleanup
  rm "$busybox_pkg_dir/bin/$script"
done

echo 'Test setup for install_scripts_via_cli: provide install script via CLI'
for script in postinst postrm preinst prerm; do
  "$build_dir/bin/hab-pkg-deb" --testname "cli_includes_$script" "--$script" "$test_dir/inputs/2/$script" core/busybox
done

echo 'Test setup for pkg_relationships_via_cli: provide package relationship via CLI'
"$build_dir/bin/hab-pkg-deb" --testname conflicts --conflicts snape core/busybox
"$build_dir/bin/hab-pkg-deb" --testname depends --depends hermione core/busybox
"$build_dir/bin/hab-pkg-deb" --testname provides --provides harry core/busybox
"$build_dir/bin/hab-pkg-deb" --testname replaces --replaces draco core/busybox

echo 'Test setup for pkg_name_via_cli: provide exported package name via CLI'
"$build_dir/bin/hab-pkg-deb" --testname "set_debname" --debname hogwarts core/busybox

echo 'Test setup for cli_provides_priority: provide priority via CLI'
"$build_dir/bin/hab-pkg-deb" --testname "cli_override_priority" --priority highest core/busybox

echo 'Test setup for pkg_provides_control_template: package provides its own control template'
install -d "$busybox_pkg_dir/export"
install -v -D -m 0644 "$test_dir/inputs/export/deb/control" "$busybox_pkg_dir/export/deb/control"
"$build_dir/bin/hab-pkg-deb" --testname pkg_includes_control_template core/busybox
# Cleanup
rm -rf "$busybox_pkg_dir/export"

echo 'Test setup for cli_provides_archive_name: provide the filename of the exported package via CLI'
"$build_dir/bin/hab-pkg-deb" --testname cli_provides_archive_name --archive bob.deb core/netcat
COMMENT
