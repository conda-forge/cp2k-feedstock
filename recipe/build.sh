#!/bin/bash

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  ARCH=Darwin-x86-64-conda
else
  ARCH=Linux-x86-64-conda
fi

# Note: cp2k >= 8.1 will only support openmp-enabled versions
for VERSION in ssmp sopt; do

    # make
    cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
    make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION}
    make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION} test

    # install
    cd ${SRC_DIR}
    mkdir -p ${PREFIX}/bin
    cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
    cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}
done
