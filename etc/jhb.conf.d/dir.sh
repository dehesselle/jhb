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

#   DIR_WORK (/Users/Shared/work)
#    ┃
#    ┗━━ DIR_VERSION (jhb-$VERSION)
#         ┃
#         ┣━━ DIR_BIN (bin)
#         ┣━━ DIR_ETC (etc)
#         ┣━━ DIR_INCLUDE (include)
#         ┣━━ DIR_LIB (lib)
#         ┣━━ DIR_OPT (opt)
#         ┣━━ DIR_SHARE (share)
#         ┣━━ DIR_TMP (tmp)
#         ┃
#         ┣━━ DIR_USR (usr)
#         ┃    ┗━━ DIR_SRC (src)
#         ┃
#         ┗━━ DIR_VAR (var)
#              ┣━━ DIR_BUILD (build)
#              ┣━━ DIR_LOG (log)
#              ┗━━ DIR_CACHE (cache)
#                   ┗━━ DIR_PKG (pkg)
#
# You can either override a variable directly or use a corresponding
# "*_TEMPLATE" variable if you want to reference other variables, e.g.
#
#     DIR_VERSION_TEMPLATE="\$DIR_WORK/myFoo-\$VERSION"

#--------------------------------------------------------- top level directories

DIR_WORK=$(eval echo "${DIR_WORK:-${DIR_WORK_TEMPLATE:-/Users/Shared/work}}")

DIR_VERSION=$(eval echo "${DIR_VERSION:-${DIR_VERSION_TEMPLATE:-$DIR_WORK/jhb-$VERSION}}")

#------------------------------------------------------------- below DIR_VERSION

DIR_BIN=$(eval echo "${DIR_BIN:-${DIR_BIN_TEMPLATE:-$DIR_VERSION/bin}}")
DIR_ETC=$(eval echo "${DIR_ETC:-${DIR_ETC_TEMPLATE:-$DIR_VERSION/etc}}")
DIR_INCLUDE=$(eval echo "${DIR_INCLUDE:-${DIR_INCLUDE_TEMPLATE:-$DIR_VERSION/include}}")
DIR_LIB=$(eval echo "${DIR_LIB:-${DIR_LIB_TEMPLATE:-$DIR_VERSION/lib}}")
DIR_OPT=$(eval echo "${DIR_OPT:-${DIR_OPT_TEMPLATE:-$DIR_VERSION/opt}}")
DIR_SHARE=$(eval echo "${DIR_SHARE:-${DIR_SHARE_TEMPLATE:-$DIR_VERSION/share}}")

DIR_USR=$(eval echo "${DIR_USR:-${DIR_USR_TEMPLATE:-$DIR_VERSION/usr}}")
DIR_SRC=$(eval echo "${DIR_SRC:-${DIR_SRC_TEMPLATE:-$DIR_USR/src}}")

DIR_TMP=$(eval echo "${DIR_TMP:-${DIR_TMP_TEMPLATE:-$DIR_VERSION/tmp}}")

DIR_VAR=$(eval echo "${DIR_VAR:-${DIR_VAR_TEMPLATE:-$DIR_VERSION/var}}")
DIR_BUILD=$(eval echo "${DIR_BUILD:-${DIR_BUILD_TEMPLATE:-$DIR_VAR/build}}")
DIR_LOG=$(eval echo "${DIR_LOG:-${DIR_LOG_TEMPLATE:-$DIR_VAR/log}}")

DIR_CACHE=$(eval echo "${DIR_CACHE:-${DIR_CACHE_TEMPLATE:-$DIR_VAR/cache}}")
DIR_PKG=$(eval echo "${DIR_PKG:-${DIR_PKG_TEMPLATE:-$DIR_CACHE/pkg}}")

# artifact directory
if [ -z "$DIR_ARTIFACT" ]; then
  if $CI; then
    DIR_ARTIFACT=$CI_PROJECT_DIR
  else
    DIR_ARTIFACT=$DIR_VERSION
  fi
fi

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
