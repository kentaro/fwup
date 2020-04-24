cd /home/admin/fwup
set -e

# === ENVs ===

FWUP_DESCRIPTION="Configurable embedded Linux firmware update creator and runner"
FWUP_HOMEPAGE="https://github.com/fhunleth/fwup"
FWUP_LICENSE="Apache-2.0"
FWUP_MAINTAINER="Frank Hunleth <fhunleth@troodon-software.com>"
FWUP_VENDOR="fhunleth@troodon-software.com"

BASE_DIR=/home/admin/fwup
CC=x86_64-w64-mingw32-gcc
CONFUSE_VERSION=3.2.2
CROSS_COMPILE=x86_64-w64-mingw32
LDD=ldd
LIBARCHIVE_VERSION=3.4.2
MAKE_FLAGS=-j8
MODE=windows
TRAVIS_OS_NAME=linux # Probably don't need this anymore...
ZLIB_VERSION=1.2.11

BUILD_DIR=$BASE_DIR/build/$CROSS_COMPILE
DEPS_DIR=$BUILD_DIR/deps
DEPS_INSTALL_DIR=$DEPS_DIR/usr
CONFIGURE_ARGS=--host=$CROSS_COMPILE
DOWNLOAD_DIR=$BASE_DIR/build/dl
FWUP_STAGING_DIR=$BUILD_DIR/fwup-staging
FWUP_INSTALL_DIR=$FWUP_STAGING_DIR/usr
FWUP_VERSION=$(cat $BASE_DIR/VERSION)
PKG_CONFIG_PATH=$DEPS_INSTALL_DIR/lib/pkgconfig

# === BUILD CHOCO
cd
git clone https://github.com/chocolatey/choco.git
cd choco
nuget restore src/chocolatey.sln
chmod +x build.sh
./build.sh -v

# === BUILD WINDOWS STUFF?
cd ~/fwup
./scripts/build_static.sh

# ======
# Build Windows package
rm -f fwup.exe
cp $FWUP_INSTALL_DIR/bin/fwup.exe .

mkdir -p $FWUP_INSTALL_DIR/fwup/tools
cp -f scripts/fwup.nuspec $FWUP_INSTALL_DIR/fwup/
sed -i "s/%VERSION%/$FWUP_VERSION/" $FWUP_INSTALL_DIR/fwup/fwup.nuspec
cp $FWUP_INSTALL_DIR/bin/fwup.exe $FWUP_INSTALL_DIR/fwup/tools/

cp -f scripts/VERIFICATION.txt $FWUP_INSTALL_DIR/fwup/tools/
sed -i "s/%VERSION%/$FWUP_VERSION/" $FWUP_INSTALL_DIR/fwup/tools/VERIFICATION.txt
cat scripts/LICENSE.txt LICENSE > $FWUP_INSTALL_DIR/fwup/tools/LICENSE.txt

cd $FWUP_INSTALL_DIR/fwup/
rm -f *.nupkg
mono /home/admin/choco/code_drop/chocolatey/console/choco.exe pack --allow-unofficial fwup.nuspec
cd $BASE_DIR
rm -f *.nupkg
cp $FWUP_INSTALL_DIR/fwup/*.nupkg .