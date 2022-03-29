# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# JHB variables.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

JHB_ARCHIVE=$(basename "$VER_DIR").tar.xz

# https://github.com/dehesselle/jhb
JHB_URL=https://github.com/dehesselle/jhb/releases/download/\
v$VERSION/$JHB_ARCHIVE

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
