#!/bin/bash

# select ARCH file and version
if [[ "$MACOSX_DEPLOYMENT_TARGET" == "10.9" ]]; then
  ARCH=Darwin-x86-64-conda
  VERSION=sopt
  alias nproc="sysctl -n hw.logicalcpu"
else
  ARCH=Linux-x86-64-conda
  VERSION=sopt
fi

# make
cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION}
make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION} test

# install
cd ${SRC_DIR}
mkdir ${PREFIX}/bin
cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}
