#!/usr/bin/env bash
#
# pre-commit hook:
# Check for Habitat default variables in a plan.sh file
#
# Authors:
# - Mike Fiedler <miketheman@gmail.com>

required_variables=(
  pkg_description
  pkg_license
  pkg_maintainer
  pkg_name
  pkg_origin
  pkg_source
  pkg_upstream_url
  pkg_version
)

for var in "${required_variables[@]}"
do
  if ! grep -Eq "^$var" "$@"
  then
    echo "Error detected by Check Default Variables."
    echo ""
    echo "    Unable to find '$var' in $*"
    echo ""
    echo "Ensure that your plan.sh contains all of:"
    IFS=$'\n'; echo "${required_variables[*]}"
    exit 1
  fi

done

exit 0
