# JHB configuration

Files in here are being sourced by `../../usr/bin/run-parts`

- in their lexical order _and_
- only once in case a symlink exists.

This way we don't have to prefix the filenames themselves to influnce the order of inclusion (a "poor man's dependency management").

The filename is also the prefix for any variable or function name within.

A file is not allowed to depend on any function or variable outside this directory, with the exception of functions included from `bash_d.sh`.
