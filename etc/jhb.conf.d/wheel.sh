# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install the wheel Python package.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# https://pypi.org/project/wheel
WHEEL_PIP="\
  wheel==0.40.0\
"

### functions ##################################################################

function wheel_install
{
  # shellcheck disable=SC2086 # we need word splitting here
  jhb run $JHBUILD_PYTHON_PIP install --prefix=$USR_DIR $WHEEL_PIP
}

### main #######################################################################

# Nothing here.
