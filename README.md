# bootstrapped JHBuild for macOS

This is my version of setting up JHBuild on macOS. It is inspired by and uses components of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx), but deviates from it in a few significant ways:

- It uses a [FSH](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)-inspired directory layout.

- It is fully self-contained to its directories, allowing for co-existence of multiple installations in locations of your choosing.

- It brings its own [Python.framework](https://gitlab.com/dehesselle/python_macos) to run JHBuild.

## prerequisites

Make sure the following prerequisites are met:

- A __clean environment__ is key. This is the most inconvenient requirement as it will likely conflict with how you are currently using your Mac, but it is vital.
  - Software and libraries - usually installed via package managers like Homebrew, MacPorts, Fink etc. - are known to cause problems depending on installation prefix. You cannot have software installed in the following locations:
    - `/usr/local`
    - `/opt/homebrew`
    - `/opt/local`
  - Uninstall Xquartz.
  - Use a dedicated user account to avoid any interference with the environment.
    - No customizations in dotfiles like `.profile`, `.bashrc` etc.

- There are __version recommendations__ based on known working setups, targeting the minimum supported OS versions (see [`sys.sh`](etc/jhb.conf/sys.sh)).
  - macOS Monterey 12.6
  - Xcode 13.x
  - macOS High Sierra 10.13.4 SDK (from Xcode 9.4.1) for `x86_64` architecture
  - macOS Big Sur 11.3 SDK (from Xcode 13.0) for `arm64` architecture

- An __internet connection__ is required to download all the packages.

## usage

1. Download a release archive, extract and `cd` into it.

1. _Optional:_ By default we're going to use `/Users/Shared/work` (see [`directories.sh`](etc/jhb.conf/directories.sh)) to build and install everything as that is a user-independent but user-writable location present on every macOS installation. If you're not comfortable with that, run e.g.

    ```bash
    export WRK_DIR=$HOME/my_custom_location
    ```

1. Bootstrap JHBuild by running the command

    ```bash
    usr/bin/bootstrap
    ```

   which is my version of [`jhbuild bootstrap-gtk-osx`](https://gitlab.gnome.org/GNOME/gtk-osx/-/tree/master/#bootstrapping), i.e. build and install all the modules from [`boostrap.modules`](etc/modulesets/jhb/bootstrap.modules) (that's the same module set as in gtk-osx's [`modulesets-stable`](https://gitlab.gnome.org/GNOME/gtk-osx/-/tree/master/modulesets-stable)).  
   A few additional modules will be built as well (see [`jhb.modules`](etc/modulesets/jhb/jhb.modules)) to make life easier on macOS and to cope with some specialties when working with union-mounted filesystems.  

   Depending on if you've adjusted `WRK_DIR` or not, the bootstrapping process will either build everything from source or download and extract a pre-built version.

1. Install your module sets. It is important that you keep them (`*.modules`) in a dedicated directory (including a `patches` subdirectory if any local patches are being used), as that directory is going to be copied to your bootstrapped jhb.

   ```bash
   usr/bin/jhb configure $HOME/my_modulesets/my_main_set.modules
   ```

### real-world examples

This is not theoretical work but the result of refactoring and outsourcing parts of Inkscape's build pipeline so it can be reused to build other apps on macOS. Here you can see this in production:

- [Inkscape](https://gitlab.com/inkscape/inkscape): see [`110-bootstrap_jhb.sh`](https://gitlab.com/inkscape/inkscape/-/blob/master/packaging/macos/110-bootstrap_jhb.sh), [`120-build_gtk3.sh`](https://gitlab.com/inkscape/inkscape/-/blob/master/packaging/macos/120-build_gtk3.sh)
- [Zim](https://gitlab.com/dehesselle/zim_macos): see [`110-build_gtk3.sh`](https://gitlab.com/dehesselle/zim_macos/-/blob/master/110-build_gtk3.sh)

## license

[GPL-2.0-or-later](LICENSE)
