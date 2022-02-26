# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# FSH-like directory layout

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

VER_DIR=$WRK_DIR/jhb-$VERSION
BIN_DIR=$VER_DIR/bin
ETC_DIR=$VER_DIR/etc
INC_DIR=$VER_DIR/include
LIB_DIR=$VER_DIR/lib
VAR_DIR=$VER_DIR/var
BLD_DIR=$VAR_DIR/build
PKG_DIR=$VAR_DIR/cache/pkgs
USR_DIR=$VER_DIR/usr
SRC_DIR=$USR_DIR/src
TMP_DIR=$VER_DIR/tmp
OPT_DIR=$VER_DIR/opt

### functions ##################################################################

function directories_init
{
  mkdir -p "$PKG_DIR"
}

### main #######################################################################

# Nothing here.
