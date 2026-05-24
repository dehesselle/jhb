# JHB configuration

Files in here are being sourced by `../jhb.conf.sh` using  `../../usr/bin/run-parts` (a helper tool similar to Debian's `run-parts`)

- in their lexical order _and_
- only once in case it is symlinked to.

This way the files themselves can keep their original name and don't need to be prefixed with a number to influcence the order of inclusion. (Order of inclusion is our "poor man's dependency management".)

The chosen filename is also the prefix for any variable or function name within.

A file is not allowed to depend on any function or variable outside this directory.
