# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Shell code I share between projects comes from bash_d.
# https://github.com/dehesselle/bash_d

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

# shellcheck source=../../usr/src/bash_d/bash_d.sh
source "$(dirname "${BASH_SOURCE[0]}")"/../../usr/src/bash_d/bash_d.sh
bash_d_include echo
bash_d_include error
bash_d_include lib
bash_d_include sed
