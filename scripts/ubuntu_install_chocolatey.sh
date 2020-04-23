#!/bin/bash

#
# Install the Windows packaging tools on Ubuntu
#

set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
USE_PREBUILT=false

source $BASE_DIR/scripts/common.sh

UBUNTU_CODENAME=$(lsb_release -cs)

case $UBUNTU_CODENAME in
    # 14.04 to 15.10
    trusty | utopic | vivid | wily)
        MONO_BRANCH=stable-trusty
        MONO_PACKAGES=mono-gmcs
        ;;

    # 16.04 to 17.10
    xenial | yakkety | zesty | artful)
        MONO_BRANCH=stable-xenial
        MONO_PACKAGES=mono-complete
        ;;

    # 18.04 to 19.10
    bionic | cosmic | disco | eoan)
        MONO_BRANCH=stable-bionic
        MONO_PACKAGES=mono-complete
        ;;

    *)
        MONO_BRANCH=stable-bionic
        MONO_PACKAGES=mono-complete
        ;;
esac

# Install mono if necessary
if [ ! -f /usr/bin/nuget ]; then
   sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
   echo "deb http://download.mono-project.com/repo/ubuntu ${MONO_BRANCH} main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
   sudo apt-get update
   sudo apt-get install -qq $MONO_PACKAGES nuget
fi

# Ensure that some directories exist
mkdir -p $DOWNLOAD_DIR
mkdir -p $DEPS_DIR

# Download Chocolatey
if $USE_PREBUILT; then
    if [ ! -e $DOWNLOAD_DIR/choco-${CHOCO_VERSION}-binaries.tar.gz ]; then
        # Download a prebuilt version
        cd $DOWNLOAD_DIR
        curl -LO http://files.troodon-software.com/choco/choco-${CHOCO_VERSION}-binaries.tar.gz
        cd $BASE_DIR
    fi
else
    if [ ! -e $DOWNLOAD_DIR/choco-$CHOCO_VERSION.tar.gz ]; then
        # Download the source
        curl -L -o $DOWNLOAD_DIR/choco-$CHOCO_VERSION.tar.gz https://github.com/chocolatey/choco/archive/$CHOCO_VERSION.tar.gz
    fi
fi

# Build Chocolatey if not already built
if [ ! -e $DEPS_INSTALL_DIR/chocolatey/console/choco.exe ]; then

    if $USE_PREBUILT; then
        tar xf $DOWNLOAD_DIR/choco-${CHOCO_VERSION}-binaries.tar.gz -C $DEPS_INSTALL_DIR
    else
        # https://github.com/aegif/CmisSync/issues/739#issuecomment-293484872
        cd /usr/lib/mono    # <= Experiment
        sudo mv 4.0 4.0.old # <= Experiment
        sudo ln -s 4.5 4.0  # <= Experiment
        cd $DEPS_DIR
        rm -fr choco-*
        tar xf $DOWNLOAD_DIR/choco-$CHOCO_VERSION.tar.gz
        cd choco-$CHOCO_VERSION
        nuget restore src/chocolatey.sln
        chmod +x build.sh
        echo "@@@@@@@@@@"
        cat build.sh
        ./build.sh -v
        cp -Rf code_drop/chocolatey $DEPS_INSTALL_DIR/
    fi
fi
