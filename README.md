# bootstrapped JHBuild for macOS

This is my version of setting up JHBuild on macOS. It is inspired by and uses components of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx), but deviates from it in a few significant ways:

- It uses a [FSH](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)-inspired directory layout.

- It is fully self-contained to its directories, allowing for co-existence of multiple installations in locations of your choosing.

- It uses a pre-built [Python.framework](https://gitlab.com/dehesselle/python_macos) to run JHBuild on OS X El Capitan up to macOS Monterey without relying on the system's Python. No need for virtual environments to keep things simple.

## usage

TBD

## license

[GPL-2.0-or-later](LICENSE)
