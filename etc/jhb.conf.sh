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

SELF_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
  pwd
)

CUSTOM_CONFIG=$SELF_DIR/jhb-custom.conf.sh
# copy a custom configuration file to the appropriate place
if [[ $1 == *.conf.sh ]] && [ -f "$1" ]; then
  cp "$1" "$CUSTOM_CONFIG"
fi

# source a custom configuration file if present
if [ -f "$CUSTOM_CONFIG" ]; then
  # shellcheck disable=SC1090 # file is optional
  source "$CUSTOM_CONFIG"
fi
unset CUSTOM_CONFIG

# source items from jhb.conf directory
for CONFIG_ITEM in $(
  "$SELF_DIR"/../usr/bin/run-parts list "$SELF_DIR"/jhb.conf/'*.sh'
); do
  # shellcheck disable=SC1090 # can't point to a single source here
  source "$CONFIG_ITEM"
done
unset CONFIG_ITEM

unset SELF_DIR

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
