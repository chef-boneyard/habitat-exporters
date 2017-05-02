#!/bin/bash
#
# # Usage
#
# ```
# $ hab-pkg-rpm [PKG ...]
# ```
#
# # Synopsis
#
# Create a Debian package from a set of Habitat packages.
#
# # License and Copyright
#
# ```
# Copyright: Copyright (c) 2017 Chef Software, Inc.
# License: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ```

# Default variables
pkg=
preinst=
postinst=
prerm=
postrm=
conflicts=
depends=
debname=
provides=
replaces=
safe_name=
safe_version=
priority=
group=

# defaults for the application
: ${pkg:="unknown"}

# Fail if there are any unset variables and whenever a command returns a
# non-zero exit code.
set -eu

# If the variable `$DEBUG` is set, then print the shell commands as we execute.
if [ -n "${DEBUG:-}" ]; then
  set -x
  export DEBUG
fi

# ## Help

# **Internal** Prints help
print_help() {
  printf -- "%s %s
%s
Habitat Package Debian - Create a Debian package from a set of Habitat packages
USAGE:
  %s [FLAGS] <PKG_IDENT>
FLAGS:
    --help           Prints help information
OPTIONS:
    --archive=FILE      Filename of exported Debian package. Should end in .deb.
    --conflicts=PKG     Package with which this conflicts
    --debname=NAME      Name of Debian package to be built
    --depends=PKG       Package on which this depends
    --dist_tag=DIST_TAG Distribution name for use in RPM filename
    --group=RPMGROUP    Group to be assigned to the RPM package
    --postinst=FILE     File name of script called after installation
    --postrm=FILE       File name of script called after removal
    --preinst=FILE      File name of script called before installation
    --prerm=FILE        File name of script called before removal
    --provides=PKG      Name of facility this package provides
    --replaces=PKG      Package that this replaces
    --priority=PRIORITY Priority to be assigned to the Debian package
    --testname=TESTNAME Test name used to create a staging directory for examination
ARGS:
    <PKG_IDENT>      Habitat package identifier (ex: acme/redis)
" "$program" "$version" "$author" "$program"
}

# internal** Exit the program with an error message and a status code.
#
# ```sh
# exit_with "Something bad went down" 55
# ```
exit_with() {
  if [[ "${HAB_NOCOLORING:-}" = "true" ]]; then
    printf -- "ERROR: %s\n" "$1"
  else
    case "${TERM:-}" in
      *term | xterm-* | rxvt | screen | screen-*)
        printf -- "\033[1;31mERROR: \033[1;37m%s\033[0m\n" "$1"
        ;;
      *)
        printf -- "ERROR: %s\n" "$1"
        ;;
    esac
  fi
  exit "$2"
}

# **Internal** Print a warning line on stderr. Takes the rest of the line as its
# only argument.
#
# ```sh
# warn "Checksum failed"
# ```
warn() {
  case "${TERM:-}" in
    *term | xterm-* | rxvt | screen | screen-*)
      printf -- "\033[1;33mWARN: \033[1;37m%s\033[0m\n" "$1" >&2
      ;;
    *)
      printf -- "WARN: %s\n" "$1" >&2
      ;;
  esac
}

get_script_dir () {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$( dirname "$SOURCE" )" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  done
  (cd -P "$(dirname "$SOURCE")" && pwd)
}

find_system_commands() {
  wtf=$(mktemp --version)
  if mktemp --version 2>&1 | grep -q 'GNU coreutils'; then
    _mktemp_cmd=$(command -v mktemp)
  else
    if /bin/mktemp --version 2>&1 | grep -q 'GNU coreutils'; then
      _mktemp_cmd=/bin/mktemp
    else
      exit_with "We require GNU mktemp to build applications archives; aborting" 1
    fi
  fi
}

# The size of the package when installed.
#
# Per http://www.debian.org/doc/debian-policy/ch-controlfields.html, the
# disk space is given as the integer value of the estimated installed
# size in bytes, divided by 1024 and rounded up.
installed_size() {
  du "$rpm_context" --apparent-size --block-size=1024 --summarize | cut -f1
}

# The package priority.
#
# Can be one of required, important, standard, optional, or extra.
# See https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html#s-priority
#
priority() {
  if [[ ! -z "$priority" ]]; then
    echo "$priority"
  else
    echo extra
  fi
}

# The package group.
#
# See https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/Packagers_Guide/chap-Packagers_Guide-Spec_File_Reference-Preamble.html
#
group() {
  if [[ ! -z "$group" ]]; then
    echo "$group"
  else
    echo default
  fi
}

# parse the CLI flags and options
parse_options() {
  opts="$(getopt \
    --longoptions help,version,archive:,conflicts:,debname:,depends:,dist_tag:,group:,postinst:,postrm:,preinst:,prerm:,priority:,provides:,replaces:,testname: \
    --name "$program" --options h,V -- "$@" \
  )"
  eval set -- "$opts"

  while :; do
    case "$1" in
      -h | --help)
        print_help
        exit
        ;;
      -V | --version)
        echo "$program $version"
        exit
        ;;
      --archive)
        archive=$2
        shift 2
        ;;
      --conflicts)
        conflicts=$2
        shift 2
        ;;
      --debname)
        debname=$2
        shift 2
        ;;
      --depends)
        depends=$2
        shift 2
        ;;
      --dist_tag)
        dist_tag=$2
        shift 2
	;;
      --group)
        group=$2
        shift 2
        ;;
      --postinst)
        postinst=$2
        shift 2
        ;;
      --postrm)
        postrm=$2
        shift 2
        ;;
      --preinst)
        preinst=$2
        shift 2
        ;;
      --prerm)
        prerm=$2;
        shift 2
        ;;
      --priority)
        priority=$2
        shift 2
        ;;
      --provides)
        provides=$2
        shift 2
        ;;
      --replaces)
        replaces=$2
        shift 2
        ;;
      --testname)
        testname=$2
        shift 2
        ;;
      --)
        shift
        pkg=$*
        break
        ;;
      *)
        exit_with "Unknown error" 1
        ;;
    esac
  done

  if [[ -z "$pkg" ]] || [[ "$pkg" = "--" ]]; then
    print_help
    exit_with "You must specify a Habitat package." 1
  fi

  install_dir=$(hab pkg path "$pkg")

  #
  # If *inst or *rm scripts are included with the package, use them.
  # The `bin` directory is specified because that is where automate currently drops its install scripts.
  #
  if [[ -z "$preinst" ]] && [[ -e "$install_dir/bin/preinst" ]]; then
    preinst="$install_dir/bin/preinst"
  fi

  if [[ -z "$postinst" ]] && [[ -e "$install_dir/bin/postinst" ]]; then
    postinst="$install_dir/bin/postinst"
  fi

  if [[ -z "$prerm" ]] && [[ -e "$install_dir/bin/prerm" ]]; then
    prerm="$install_dir/bin/prerm"
  fi

  if [[ -z "$postrm" ]] && [[ -e "$install_dir/bin/postrm" ]]; then
    postrm="$install_dir/bin/postrm"
  fi
}

# The name converted to all lowercase to be compatible with Debian naming
# conventions
convert_name() {
  if [[ ! -z "$debname" ]]; then
    safe_name="${debname,,}"
  else
    safe_name="${pkg_origin,,}-${pkg_name,,}"
  fi
}

# Return the Debian-ready version, replacing all dashes (-) with tildes
# (~) and converting any invalid characters to underscores (_).
convert_version() {
  if [[ $pkg_version == *"-"* ]]; then
    safe_version="${pkg_version//-/\~}"
    warn "Dashes hold special significance in the Debian package versions. "
    warn "Versions that contain a dash and should be considered an earlier "
    warn "version (e.g. pre-releases) may actually be ordered as later "
    warn "(e.g. 12.0.0-rc.6 > 12.0.0). We'll work around this by replacing "
    warn "dashes (-) with tildes (~). Converting '$pkg_version' "
    warn "to '$safe_version'."
	else
    safe_version="$pkg_version"
	fi
}

# The filename to be used for the exported Debian package.
rpmfile() {
  if [[ -z "${archive+x}" ]]; then
    if [[ -z "${dist_tag+x}" ]]; then
      echo "${safe_name}-$safe_version-${pkg_release}.$(architecture).rpm"
    else
      echo "${safe_name}-$safe_version-${pkg_release}.${dist_tag}.$(architecture).rpm"
    fi
  else
    echo "$archive"
  fi
}

description() {
  pkg_description="$(head -2 <<< "$manifest" | tail -1)"

  # TODO: Handle multi-line descriptions.
  # See https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Description
  # Handle empty pkg_description
  if [[ -z "$pkg_description" ]]; then
    if [[ ! -z "$debname" ]]; then
      echo "$debname"
    else
      echo "$pkg_name"
    fi
  else
    echo "$pkg_description"
  fi
}

maintainer() {
  pkg_maintainer="$(grep __Maintainer__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"

  if [[ -z "$pkg_maintainer" ]]; then
    echo "$pkg_origin"
  else
    echo "$pkg_maintainer"
  fi
}

release() {
 # Release: <%= iteration %><%= dist_tag ? dist_tag : '' %>
  if [[ -z "${dist_tag+x}" ]]; then
    echo "$pkg_release"
  else
    echo "${pkg_release}.${dist_tag}"
  fi
}

# Output the contents of the "control" file
render_spec_file() {
  spec_template="$(get_script_dir)/../export/rpm/spec"
  if [[ -f "$install_dir/export/rpm/spec" ]]; then
    spec_template="$install_dir/export/rpm/spec"
  fi

  hab pkg exec core/handlebars-cmd handlebars \
    --name "$safe_name" \
    --version "$safe_version" \
    --release "$(release)" \
    --description "$(description)" \
    --group "$(group)" \
    --license "$pkg_license" \
    --vendor "$pkg_origin" \
    --url "$pkg_upstream_url" \
    --packager "$(maintainer)" \
    --architecture "$(architecture)" \
    --installed_size "$(installed_size)" \
    --priority "$(priority)" \
    --pkg_upstream_url "$pkg_upstream_url" \
    --conflicts "$conflicts" \
    --depends "$depends" \
    --provides "$provides" \
    --replaces "$replaces" \
    < "$spec_template" \
    > "$staging/SPECS/$safe_name.spec"
}

write_conffiles() {
  if [[ -f "$install_dir/export/deb/conffiles" ]]; then
    install -v -m 0555 "$install_dir/export/deb/conffiles" "$staging/DEBIAN/conffiles"
  fi
}

write_scripts() {
  for script_name in preinst postinst prerm postrm; do
    eval "file_name=\$$script_name"
    if [[ -n $file_name ]]; then
      if [[ -f $file_name ]]; then
        install -v -m 0755 "$file_name" "$staging/DEBIAN/$script_name"
      else
        exit_with "$script_name script '$file_name' not found" 1
      fi
    fi
  done
}

render_md5sums() {
  pushd "$rpm_context" > /dev/null
    find . -type f ! -regex '.*?DEBIAN.*' -exec md5sum {} +
  popd > /dev/null
}

# The platform architecture.
architecture() {
  rpm --eval "%{_arch}"
}

build_rpm() {
  rpm_context="$($_mktemp_cmd -t -d "${program}-XXXX")"
  pushd "$rpm_context" > /dev/null

  env PKGS="$pkg" NO_MOUNT=1 hab studio -r "$rpm_context" -t bare new
  echo "$pkg" > "$rpm_context"/.hab_pkg
  popd > /dev/null

  # Stage the files to be included in the exported .deb package.
  if [[ ! -z "${testname+x}" ]]; then
    staging="/tmp/test-${program}-${testname}"
    mkdir "$staging"
  else
    staging="$($_mktemp_cmd -t -d "${program}-staging-XXXX")"
  fi

  # Magic RPM directories
  mkdir "$staging/BUILD"
  mkdir "$staging/RPMS"
  mkdir "$staging/SRPMS"
  mkdir "$staging/SOURCES"
  mkdir "$staging/SPECS"
  mkdir "$staging/BUILD/hab"

  # Read the manifest to extract variables from it
  manifest="$(cat "$install_dir/MANIFEST")"

  pkg_license="$(grep __License__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"
  pkg_upstream_url="$(grep '__Upstream URL__' <<< "$manifest" | cut -d ":" -f2- | cut -d '(' -f1 | sed 's/[][]//g' | sed 's/^[\t ]*//g')"

  # Get the ident and the origin and release from that
  ident="$(cat "$install_dir/IDENT")"

  pkg_origin="$(echo "$ident" | cut -f1 -d/)"
  pkg_name="$(echo "$ident" | cut -f2 -d/)"
  pkg_version="$(echo "$ident" | cut -f3 -d/)"
  pkg_release="$(echo "$ident" | cut -f4 -d/)"

  convert_name
  convert_version

  # Write the spec file
  render_spec_file

  # If user provides a conffiles file in export/deb, it will be installed for inclusion in the exported package.
  write_conffiles

  write_scripts

  # Copy needed files into staging directory
  cp -pr "$rpm_context/hab/pkgs" "$staging/BUILD/hab"
  cp -pr "$rpm_context/hab/bin" "$staging/BUILD/hab"

  # For most testing, it is enough to generate the spec file and RPM name without building the full package.
  if [[ -z "${testname+x}" ]]; then
    rpmbuild --target "$(architecture)" -bb --buildroot "$staging/BUILD" --define \'_topdir "$staging"\' "$staging/SPECS/$safe_name.spec"
  else
    printf "%s" "$(rpmfile)" > "$staging/rpm_name"
  fi
}

# The current version of Habitat this program
version='@version@'

# The author of this program
author='@author@'

# The short version of the program name which is used in logging output
program=$(basename "$0")

find_system_commands

parse_options "$@"
build_rpm

rm -rf "$rpm_context"
if [[ -z "${testname+x}" ]]; then
  rm -rf "$staging"
fi
