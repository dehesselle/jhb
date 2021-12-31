# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Shell code I share between projects comes from bash_d.
# https://github.com/dehesselle/bash_d

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

INCLUDE_DIR=$(dirname "${BASH_SOURCE[0]}")/../../usr/src/bash_d

### functions ##################################################################

# Nothing here.

### main #######################################################################

# shellcheck source=../../usr/src/bash_d/1_include.sh
source "$INCLUDE_DIR"/1_include.sh
include_file echo
include_file error
include_file lib
include_file sed
