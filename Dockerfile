# ABOUT THIS FILE:
#   This is an image for a system that can reliably build
#   and test a Windows release of fwup.
FROM ubuntu:18.04
RUN apt-get update --yes && \
  apt-get install apt-transport-https dirmngr gnupg ca-certificates gnupg ca-certificates sudo git --yes && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
  echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
  apt update --yes && \
  apt install autoconf build-essential curl gcc-mingw-w64-x86-64 libtool libarchive-dev mono-devel mtools pkg-config software-properties-common dosfstools zip unzip nuget wine-stable wine-binfmt wget xdelta3 --yes && \
  useradd -m admin && \
  adduser admin sudo && \
  echo "admin:admin" | chpasswd && \
  dpkg --add-architecture i386 && \
  wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
  apt-key add winehq.key && \
  apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \
  apt update && \
  add-apt-repository ppa:cybermax-dexter/sdl2-backport --yes && \
  apt install --install-recommends winehq-stable --yes && \
  apt-get install -qq gcc-mingw-w64-x86-64 && \
  apt-get install wine-binfmt && \
  apt-get update && \
  update-binfmts --import /usr/share/binfmts/wine
COPY . /home/admin/fwup
RUN chown -R admin:admin /home/admin
USER admin
