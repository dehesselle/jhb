# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# System and version checks.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

if [ "$SYS_USRLOCAL_IGNORE" != "false" ]; then
  SYS_USRLOCAL_IGNORE=true
fi

SYS_MACOS_VER=$(sw_vers -productVersion)

SYS_SDK_VER="$(/usr/libexec/PlistBuddy -c \
  "Print :DefaultProperties:MACOSX_DEPLOYMENT_TARGET" \
  "$SDKROOT"/SDKSettings.plist)"

### functions ##################################################################

function sys_create_log
{
  # Create jhb.log file.

  for var in SYS_MACOS_VER SYS_SDK_VER VERSION VER_DIR WRK_DIR; do
    echo "$var = $(eval echo \$$var)" >>"$LOG_DIR"/jhb.log
  done
}

function sys_usrlocal_is_clean
{
  local count=0

  # Based on GitHub CI experience, it appears to be enough to make sure
  # the following folders do not contain files.
  for dir in include lib share; do
    count=$((count + \
      $(find /usr/local/$dir -type f 2>/dev/null | wc -l | awk '{ print $1 }')))
  done

  if [ "$count" -ne 0 ]; then
    if $SYS_USRLOCAL_IGNORE; then
      echo_w "Found files in '/usr/local/[include|lib|share]'."
    else
      echo_e "Found files in '/usr/local/[include|lib|share]'!"
      echo_e "This is known to cause trouble, but you can downgrade this error"
      echo_e "to a warning at your own risk:"
      echo_e " "
      echo_e "    export SYS_USRLOCAL_IGNORE=true"
      return 1
    fi
  fi

  return 0
}

function sys_wrkdir_is_usable
{
  if mkdir -p "$WRK_DIR" 2>/dev/null && [ -w "$WRK_DIR" ]; then
    return 0 # WRK_DIR has been created or was already there and is writable
  else
    echo_e "WRK_DIR not usable: $WRK_DIR"
    return 1
  fi
}

### main #######################################################################

# Nothing here.
