# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Recommended versions that functions from sys.sh are going to check
# the system against.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

RECOMMENDED_MACOS_VER_X86_64=${RECOMMENDED_MACOS_VER_X86_64:-11.6.7}
RECOMMENDED_MACOS_VER_ARM64=${RECOMMENDED_MACOS_VER_ARM64:-11.6.7}

RECOMMENDED_SDK_VER_X86_64=${RECOMMENDED_SDK_VER_X86_64:-10.11}
RECOMMENDED_SDK_VER_ARM64=${RECOMMENDED_SDK_VER_ARM64:-11.3}

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
