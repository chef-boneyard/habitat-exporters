#!/bin/bash
#
# # Usage
#
# ```
# $ hab-pkg-deb [PKG ...]
# ```
#
# # Synopsis
#
# Create a Debian package from a set of Habitat packages.
#
# # License and Copyright
#
# ```
# Copyright: Copyright (c) 2016-2017 Chef Software, Inc.
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
provides=
replaces=
safe_name=
safe_version=

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
  printf -- "$program $version
$author
Habitat Package Debian - Create a Debian package from a set of Habitat packages
USAGE:
  $program [FLAGS] <PKG_IDENT>
FLAGS:
    --help           Prints help information
OPTIONS:
    --preinst=FILE   File name of script called before installation
    --postinst=FILE  File name of script called after installation
    --prerm=FILE     File name of script called before removal
    --postrm=FILE    File name of script called after removal
    --conflicts=PKG  Package that this conflicts with
    --provides=PKG   Name of facility this package provides
    --replaces=PKG   Package that this replaces
ARGS:
    <PKG_IDENT>      Habitat package identifier (ex: acme/redis)
"
}

# internal** Exit the program with an error message and a status code.
#
# ```sh
# exit_with "Something bad went down" 55
# ```
exit_with() {
  if [ "${HAB_NOCOLORING:-}" = "true" ]; then
    printf -- "ERROR: $1\n"
  else
    case "${TERM:-}" in
      *term | xterm-* | rxvt | screen | screen-*)
        printf -- "\033[1;31mERROR: \033[1;37m$1\033[0m\n"
        ;;
      *)
        printf -- "ERROR: $1\n"
        ;;
    esac
  fi
  exit $2
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
      printf -- "\033[1;33mWARN: \033[1;37m$1\033[0m\n" >&2
      ;;
    *)
      printf -- "WARN: $1\n" >&2
      ;;
  esac
}

find_system_commands() {
  wtf=$(mktemp --version)
  if $(mktemp --version 2>&1 | grep -q 'GNU coreutils'); then
    _mktemp_cmd=$(command -v mktemp)
  else
    if $(/bin/mktemp --version 2>&1 | grep -q 'GNU coreutils'); then
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
  du "$deb_context" --apparent-size --block-size=1024 --summarize | cut -f1
}

# The package priority.
#
# Can be one of required, important, standard, optional, or extra.
# See https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html#s-priority
#
# TODO: Allow customizing this
priority() {
  echo extra
}

# The package section.
#
# See https://www.debian.org/doc/debian-policy/ch-archive.html#s-subsections
#
# TODO: Allow customizing this
section() {
  echo misc
}

# parse the CLI flags and options
parse_options() {
  echo "@=$@"
  opts="$(getopt \
    --longoptions help,version,preinst:,postinst:,prerm:,postrm:,conflicts:,provides:,replaces: \
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
      --preinst)
        preinst=$2
        shift 2
        ;;
      --postinst)
        postinst=$2
        shift 2
        ;;
      --prerm)
        prerm=$2;
        shift 2
        ;;
      --postrm)
        postrm=$2
        shift 2
        ;;
      --conflicts)
        conflicts=$2
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
  if [ -z "$pkg" ] || [ "$pkg" = "--" ]; then
    print_help
    exit_with "You must specify a Habitat package." 1
  fi
}

# The name converted to all lowercase to be compatible with Debian naming
# conventions
convert_name() {
  safe_name="${pkg_origin,,}-${pkg_name,,}"
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

# Output the contents of the "control" file
render_control_file() {
# TODO: Depends/conflicts/provides, etc. See https://www.debian.org/doc/debian-policy/ch-relationships.html
# TODO: Should vendor be the origin or not?
control=$(cat <<EOF
Package: $safe_name
Version: $safe_version-$pkg_release
Vendor: $pkg_origin
Architecture: $(architecture)
Installed-Size: $(installed_size)
Section: $(section)
Priority: $(priority)
EOF
)

# TODO: Format the description correctly
# See https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Description
if [[ ! -z $pkg_description ]]; then
  control="$control
Description: $pkg_description"
# Description is required, so just use the package name if we don't have one
else
  control="$control
Description: $pkg_name"
fi

if [[ ! -z $pkg_upstream_url ]]; then
  control="$control
Homepage: $pkg_upstream_url"
fi

if [[ ! -z $pkg_license ]]; then
  control="$control
License: $pkg_license"
fi

if [[ ! -z $pkg_maintainer ]]; then
  control="$control
Maintainer: $pkg_maintainer"
# Maintainer is required, so use the origin if we don't have one
else
  control="$control
Maintainer: $pkg_origin"
fi

if [[ ! -z $conflicts ]]; then
  control="$control
Conflicts: $conflicts"
fi

if [[ ! -z $provides ]]; then
  control="$control
Provides: $provides"
fi

if [[ ! -z $replaces ]]; then
  control="$control
Replaces: $replaces"
fi

echo "$control"
}

write_scripts() {
  for script_name in preinst postinst prerm postrm; do
    eval "file_name=\$$script_name"
    if [[ -n $file_name ]]; then
      if [[ -f $file_name ]]; then
        install -v -m 0755 "$file_name" "$deb_context/DEBIAN/$script_name"
      else
        exit_with "$script_name script '$file_name' not found" 1
      fi
    fi
  done
}

render_md5sums() {
  pushd "$deb_context" > /dev/null
    find . -type f ! -regex '.*?DEBIAN.*' -exec md5sum {} +
  popd > /dev/null
}

# The platform architecture.
architecture() {
  dpkg --print-architecture
}

build_deb() {
  deb_context="$($_mktemp_cmd -t -d "${program}-XXXX")"
  pushd $deb_context > /dev/null

  env PKGS="$pkg" NO_MOUNT=1 hab studio -r $deb_context -t bare new
  echo $pkg > $deb_context/.hab_pkg
  popd > /dev/null

  mkdir "$deb_context/DEBIAN"

  # Set these variables in advance, since they may or may not be in the manifest,
  # since they are optional
  pkg_description=
  pkg_license=
  pkg_maintainer=
  pkg_upstream_url=

  install_dir="$(hab pkg path "$pkg")"

  # Read the manifest to extract variables from it
  manifest="$(cat "$install_dir/MANIFEST")"

  # TODO: Handle multi-line descriptions
  # FIXME: This probably fail when there's a ":" in them
  pkg_description="$(grep __Description__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"
  pkg_license="$(grep __License__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"
  pkg_maintainer="$(grep __Maintainer__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"
  pkg_upstream_url="$(grep __Upstream\ URL__: <<< "$manifest" | cut -d ":" -f2 | sed 's/^ *//g')"

  # Get the ident and the origin and release from that
  ident="$(cat "$install_dir/IDENT")"

  pkg_origin="$(echo "$ident" | cut -f1 -d/)"
  pkg_name="$(echo "$ident" | cut -f2 -d/)"
  pkg_version="$(echo "$ident" | cut -f3 -d/)"
  pkg_release="$(echo "$ident" | cut -f4 -d/)"

  convert_name
  convert_version

  # Write the control file
  render_control_file > "$deb_context/DEBIAN/control"

  # TODO: Write conffiles file
  write_scripts

  render_md5sums > "$deb_context/DEBIAN/md5sums"

  dpkg-deb -z9 -Zgzip --debug --build "$deb_context" \
    "${safe_name}_$safe_version-${pkg_release}_$(architecture).deb"
}

# The short version of the program name which is used in logging output
program=$(basename $0)

find_system_commands

parse_options $@
build_deb
