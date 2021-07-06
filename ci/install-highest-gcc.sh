#!/bin/bash
INSTALLED_VERSION=$(find /usr/bin /usr/local/bin -name g++-* -printf '%f\n' | grep -oP 'g\+\+-\K\d+' | sort -rn | head -n1)
INSTALLABLE_VERSION=$(apt-cache dumpavail | grep -oP 'g\+\+-\K\d+' | sort -rn | head -n1)

if [[ "$INSTALLED_VERSION" != "" && "$INSTALLABLE_VERSION" -le "$INSTALLED_VERSION" ]]; then
  exit
fi

GCC_VERSION="gcc-${INSTALLABLE_VERSION}"
GXX_VERSION="g++-${INSTALLABLE_VERSION}"
apt-get install -y "$GXX_VERSION"

update-alternatives --install /usr/bin/gcc gcc "/usr/bin/$GCC_VERSION" 10
update-alternatives --install /usr/bin/g++ g++ "/usr/bin/$GXX_VERSION" 10
