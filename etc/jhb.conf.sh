# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This is a convenience wrapper to source all individual configuration files.
# It also takes care of placing a custom configuration file in the appropriate
# location.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

_SELF_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
  pwd
)

_CUSTOM_CONFIG=$_SELF_DIR/jhb-custom.conf.sh
# copy a custom configuration file to the appropriate place
if [[ $1 == *.conf.sh ]] && [ -f "$1" ]; then
  cp "$1" "$_CUSTOM_CONFIG"
fi

# source a custom configuration file if present
if [ -f "$_CUSTOM_CONFIG" ]; then
  # shellcheck disable=SC1090 # file is optional
  source "$_CUSTOM_CONFIG"
fi
unset _CUSTOM_CONFIG

# source items from jhb.conf.d directory
for _CONFIG_ITEM in $(
  "$_SELF_DIR"/../usr/bin/run-parts list "$_SELF_DIR"/jhb.conf.d/'*.sh'
); do
  # shellcheck disable=SC1090 # can't point to a single source here
  source "$_CONFIG_ITEM"
done
unset _CONFIG_ITEM

unset _SELF_DIR

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
