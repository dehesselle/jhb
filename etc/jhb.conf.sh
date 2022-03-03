# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This is a convenience wrapper to source all individual configuration files.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### includes ###################################################################

# shellcheck disable=SC1090 # can't point to a single source here
for CONFIG in $(\
    "$(dirname "${BASH_SOURCE[0]}")"/../usr/bin/run-parts list \
        "$(dirname "${BASH_SOURCE[0]}")"/jhb.conf/'*.sh' \
    ); do
  source "$CONFIG"
done
unset CONFIG

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.