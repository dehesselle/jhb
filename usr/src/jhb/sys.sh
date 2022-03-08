# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# System information and checks.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # no exports desired

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

SYS_MACOS_VER=$(sw_vers -productVersion)

SYS_SDK_VER=$(/usr/libexec/PlistBuddy -c "Print \
:DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)

if [ "$SYS_IGNORE_USR_LOCAL" != "true" ]; then
  SYS_IGNORE_USR_LOCAL=false
fi

### functions ##################################################################

function sys_check_versions
{
  # Check version recommendations.

  local arch
  arch=$(uname -m | tr '[:lower:]' '[:upper:]')
  local recommended_macos_ver
  recommended_macos_ver=$(eval echo \$RECOMMENDED_MACOS_VER_"$arch")
  local recommended_sdk_ver
  recommended_sdk_ver=$(eval echo \$RECOMMENDED_SDK_VER_"$arch")

  if [ "$SYS_SDK_VER" != "$recommended_sdk_ver" ]; then
    echo_w "recommended   SDK: $(printf '%8s' "$recommended_sdk_ver")"
    echo_w "       your   SDK: $(printf '%8s' "$SYS_SDK_VER")"
  fi

  if [ "$SYS_MACOS_VER" != "$recommended_macos_ver" ]; then
    echo_w "recommended macOS: $(printf '%8s' "$recommended_macos_ver")"
    echo_w "       your macOS: $(printf '%8s' "$SYS_MACOS_VER")"
  fi
}

function sys_create_log
{
  # Create jhb.log file.

  mkdir -p "$VAR_DIR"/log

  for var in SYS_MACOS_VER SYS_SDK_VER VERSION VER_DIR WRK_DIR; do
    echo "$var = $(eval echo \$$var)" >> "$VAR_DIR"/log/jhb.log
  done
}

function sys_check_wrkdir
{
  if  mkdir -p "$WRK_DIR" 2>/dev/null &&
      [ -w "$WRK_DIR" ] ; then
    : # WRK_DIR has been created or was already there and is writable
  else
    echo_e "WRK_DIR not usable: $WRK_DIR"
    return 1
  fi
}

function sys_check_sdkroot
{
  if [ ! -d "$SDKROOT" ]; then
    echo_e "SDK not found: $SDKROOT"
    return 1
  fi
}

function sys_check_usr_local
{
  local count=0

  # Taken from GitHub CI experience, it appears to be enough to make sure
  # the following folders do not contain files.
  for dir in include lib share; do
    count=$(( count + \
      $(find /usr/local/$dir -type f 2>/dev/null | wc -l | awk '{ print $1 }')\
    ))
  done

  if [ "$count" -ne 0 ]; then
    if $SYS_IGNORE_USR_LOCAL; then
      echo_w "Found files in '/usr/local/[include|lib|share]'."
      echo_w "You chose to continue anyway, good luck!        "
    else
      echo_e "Found files in '/usr/local/[include|lib|share]. Will not continue"
      echo_e "as this is an unsupported configuraiton, known to cause trouble. "
      echo_e "However, you can use                                             "
      echo_e "                                                                 "
      echo_e "    export SYS_IGNORE_USR_LOCAL=true                             "
      echo_e "                                                                 "
      echo_e "to ignore this error at your own risk.                           "
      return 1
    fi
  fi
}

### main #######################################################################

# Nothing here.