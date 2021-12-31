# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Directory to place the build artifact in.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

if   $CI_GITHUB; then
  ARTIFACT_DIR=$GITHUB_WORKSPACE
elif $CI_GITLAB; then
  ARTIFACT_DIR=$CI_PROJECT_DIR
else
  ARTIFACT_DIR=$VER_DIR
fi

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
