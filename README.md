# bootstrapped JHBuild for macOS

![jhb_icon](./share/jhb/logo.png)
![pipeline status](https://gitlab.com/dehesselle/jhb/badges/master/pipeline.svg)
![Latest Release](https://gitlab.com/dehesselle/jhb/-/badges/release.svg)

This project (on [GitLab](https://gitlab.com/dehesselle/jhb), [GitHub](https://github.com/dehesselle/jhb)) is my take on setting up [JHBuild](https://gitlab.gnome.org/GNOME/jhbuild) on macOS in order to build GTK-based apps. It is inspired by and uses components of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx), but deviates from it in a few significant ways:

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
  - Undo any customizations in dotfiles like `.profile`, `.bashrc` etc. that interfere with the environment.
    - If in doubt, use a dedicated user account instead.

- There are __version recommendations__ based on known working setups.
  - macOS >= 11.x (latest version)
  - Xcode >= 13.x
  - macOS High Sierra 10.13.4 SDK (from Xcode 9.4.1) for `x86_64` architecture
  - macOS Big Sur 11.3 SDK (from Xcode 13.0) for `arm64` architecture

- An __internet connection__ is required to download all the packages.

## usage

1. Clone the latest version of this repository.

    ```bash
    git clone https://github.com/dehesselle/jhb
    cd jhb
    # checkout tag with highest version number
    git checkout $(git tag | grep "^v" | sort -V | tail -1)
    # pull in submodules
    git submodule update --init --recursive
    ```

2. 💁 _This is an optional step. You are encouraged to skip this!_  
   By default we're going to use `/Users/Shared/work` (see [`directories.sh`](etc/jhb.conf.d/directories.sh)) to build and install everything as that is a user-independent but user-writable location present on every macOS installation. If you're not comfortable with that, run e.g.

    ```bash
    export WRK_DIR=$HOME/my_custom_location
    ```

3. Bootstrap JHBuild by running the following command.

    ```bash
    usr/bin/bootstrap
    ```

   This is the equivalent to gtk-osx's [`jhbuild bootstrap-gtk-osx`](https://gitlab.gnome.org/GNOME/gtk-osx/-/tree/master/#bootstrapping), i.e. build and install all the modules from [`boostrap.modules`](etc/modulesets/jhb/bootstrap.modules). A few additional modules will be built as well (see [`jhb.modules`](etc/modulesets/jhb/jhb.modules)) to make life easier on macOS.

   Depending on wether you've skipped step 2 or not, the bootstrapping process will either download and extract an archive containing everything pre-built (and you're done in a minute) or start to build everything from source (this will take a while).

4. Install your own module sets (`*.modules`). It is important that you keep them all together in a dedicated directory (including a `patches` subdirectory if any local patches are being used) as that whole directory is going to be copied to your bootstrapped jhb.

    ```bash
    # specify your main file here
    usr/bin/jhb configure $HOME/my_modulesets/my_main_set.modules
    ```

### real-world examples

This is not theoretical work but the result of refactoring and outsourcing parts of Inkscape's build pipeline so it can be reused to build other GTK-based apps on macOS. Here you can see this being used in production:

- [Inkscape](https://gitlab.com/inkscape/inkscape): see [deps.macos](https://gitlab.com/inkscape/deps/macos)
- [Siril](https://siril.org): see [siril_macos](https://gitlab.com/free-astro/siril_macos)
- [Rnote](https://rnote.flxzt.net): see [rnote_macos](https://gitlab.com/dehesselle/rnote_macos)

## credits

The jhb logo uses modified versions of

- a [construction sign](https://openclipart.org/detail/89593/construction-sign-simple), licensed under [CC0-1.0](https://spdx.org/licenses/CC0-1.0.html)
- the [GTK logo](https://commons.wikimedia.org/wiki/File:GTK_logo.svg) from Andreas Nilsen, licensed under [CC-BY-SA-3.0](https://spdx.org/licenses/CC-BY-SA-3.0.html)

## license

[GPL-2.0-or-later](LICENSE)
