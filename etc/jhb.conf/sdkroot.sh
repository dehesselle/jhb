# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# If SDKROOT is set, use that. If it is not set, use whatever SDK is available
# available. This might still end up being invalid if neither Xcode nor CLT
# have been installed and it will be sys_check_sdkroot's job to complain and
# bail.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

if [ -z "$SDKROOT" ]; then
  if xcodebuild --help 2>/dev/null; then
    SDKROOT=$(xcodebuild -version -sdk macosx Path)
  else
    SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
  fi
fi
export SDKROOT

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
