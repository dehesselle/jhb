# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Release artifact.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

RELEASE_ARCHIVE=${RELEASE_ARCHIVE:-$(\
  basename "$DIR_VERSION")_$(uname -m).tar.xz}

# The canonical source for releases is GitLab.
RELEASE_URL="https://gitlab.com/api/v4/projects/35965804/packages/generic/jhb/\
v$VERSION/$RELEASE_ARCHIVE"

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
