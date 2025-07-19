# SPDX-FileCopyrightText: 2025 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# abcreate is a Python package that creates an application bundle from an
# install prefix dir.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# https://github.com/dehesselle/abcreate
ABCREATE_PIP=(
  "abcreate==0.6"
  "annotated-types==0.7.0"
  "lxml==6.0.0"
  "pydantic==2.11.7"
  "pydantic_core==2.33.2"
  "typing-inspection==0.4.1"
  "typing_extensions==4.14.1"
)

### functions ##################################################################

function abcreate_install
{
  jhb run pip3 install --prefix="$VER_DIR" "${ABCREATE_PIP[@]}"
}

### main #######################################################################

# Nothing here.
