# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Redirect pip cache directories.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

export PIP_CACHE_DIR=$CAC_DIR/pip       # instead ~/Library/Caches/pip
export PIPENV_CACHE_DIR=$CAC_DIR/pipenv # instead ~/Library/Caches/pipenv
export PYTHONPYCACHEPREFIX=$CAC_DIR/pycache

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
