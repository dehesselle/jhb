# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Set cache directory for ccache.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

export CCACHE_DIR=${CCACHE_DIR:-$WRK_DIR/ccache}

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
