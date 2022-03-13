# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This is a convenience wrapper to source all individual configuration files.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### includes ###################################################################

# source a custom configuration file if present
if [ -f "$(dirname "${BASH_SOURCE[0]}")"/jhb-custom.conf.sh ]; then
  # shellcheck disable=SC1091 # file is optional
  source "$(dirname "${BASH_SOURCE[0]}")"/jhb-custom.conf.sh
fi

# source items from jhb.conf directory
for CONFIG_ITEM in $(\
    "$(dirname "${BASH_SOURCE[0]}")"/../usr/bin/run-parts list \
        "$(dirname "${BASH_SOURCE[0]}")"/jhb.conf/'*.sh' \
    ); do
  # shellcheck disable=SC1090 # can't point to a single source here
  source "$CONFIG_ITEM"
done
unset CONFIG_ITEM

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.