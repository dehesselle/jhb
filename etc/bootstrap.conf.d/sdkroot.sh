# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# If SDKROOT is set, use that. If it is not set, try to select the 10.11 SDK
# (which is our minimum system requirement/target) and fallback to whatever
# SDK is available as the default one.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

if [ -z "$SDKROOT" ]; then
  SDKROOT=/opt/sdks/MacOSX10.11.sdk
  if [ ! -d "$SDKROOT" ]; then
    SDKROOT=$(xcodebuild -version -sdk macosx Path)
  fi
fi
export SDKROOT

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
