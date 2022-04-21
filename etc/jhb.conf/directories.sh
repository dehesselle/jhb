# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# FSH-inspired directory layout

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

#--------------------------------------------------------- main directory layout

#   WRK_DIR (/Users/Shared/work)
#    ┃
#    ┣━━ REP_DIR (repo)
#    ┃
#    ┗━━ VER_DIR (jhb-$VERSION)
#         ┃
#         ┣━━ BIN_DIR (bin)
#         ┣━━ ETC_DIR (etc)
#         ┣━━ INC_DIR (include)
#         ┣━━ LIB_DIR (lib)
#         ┣━━ OPT_DIR (opt)
#         ┃
#         ┣━━ TMP_DIR (tmp)
#         ┃
#         ┣━━ USR_DIR (usr)
#         ┃    ┗━━ SRC_DIR (src)
#         ┃
#         ┗━━ VAR_DIR (var)
#              ┣━━ BLD_DIR (build)
#              ┗━━ PKG_DIR (cache/pkg)
#
# You can either override a variable directly or use a corresponding
# "*_TEMPLATE" variable if you want to reference other variables, e.g.
#
#     VER_DIR_TEMPLATE="\$WRK_DIR/myFoo-\$VERSION"

WRK_DIR=$(eval echo "${WRK_DIR:-${WRK_DIR_TEMPLATE:-/Users/Shared/work}}")

REP_DIR=$(eval echo "${REP_DIR:-${REP_DIR_TEMPLATE:-$WRK_DIR/repo}}")

VER_DIR=$(eval echo "${VER_DIR:-${VER_DIR_TEMPLATE:-$WRK_DIR/jhb-$VERSION}}")

BIN_DIR=$(eval echo "${BIN_DIR:-${BIN_DIR_TEMPLATE:-$VER_DIR/bin}}")
ETC_DIR=$(eval echo "${ETC_DIR:-${ETC_DIR_TEMPLATE:-$VER_DIR/etc}}")
INC_DIR=$(eval echo "${INC_DIR:-${INC_DIR_TEMPLATE:-$VER_DIR/include}}")
LIB_DIR=$(eval echo "${LIB_DIR:-${LIB_DIR_TEMPLATE:-$VER_DIR/lib}}")
OPT_DIR=$(eval echo "${OPT_DIR:-${OPT_DIR_TEMPLATE:-$VER_DIR/opt}}")

USR_DIR=$(eval echo "${USR_DIR:-${USR_DIR_TEMPLATE:-$VER_DIR/usr}}")
SRC_DIR=$(eval echo "${SRC_DIR:-${SRC_DIR_TEMPLATE:-$USR_DIR/src}}")

TMP_DIR=$(eval echo "${TMP_DIR:-${TMP_DIR_TEMPLATE:-$VER_DIR/tmp}}")

VAR_DIR=$(eval echo "${VAR_DIR:-${VAR_DIR_TEMPLATE:-$VER_DIR/var}}")
BLD_DIR=$(eval echo "${BLD_DIR:-${BLD_DIR_TEMPLATE:-$VAR_DIR/build}}")
PKG_DIR=$(eval echo "${PKG_DIR:-${PKG_DIR_TEMPLATE:-$VAR_DIR/cache/pkg}}")

#------------------------------------------------------------ artifact directory

if [ -z "$ARTIFACT_DIR" ]; then
  if   $CI_GITHUB; then
    ARTIFACT_DIR=$GITHUB_WORKSPACE
  elif $CI_GITLAB; then
    ARTIFACT_DIR=$CI_PROJECT_DIR
  else
    ARTIFACT_DIR=$VER_DIR
  fi
fi

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.