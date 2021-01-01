#!/bin/bash
set -e

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  ARCH=Darwin-x86-64-conda
else
  ARCH=Linux-x86-64-conda
fi

VERSION=psmp

# make
cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION}

# run regression tests
# Use built-in threading for regtests to limit memory usage (encountered SIGABORT otherwise)
OMP_NUM_THREADS=1
export OMP_NUM_THREADS
make ARCH=${ARCH} VERSION=${VERSION} test

# install
cd ${SRC_DIR}
mkdir -p ${PREFIX}/bin
cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}

# Symlink cp2k.sopt for backwards compatibility of conda-forge package
# Note: cp2k >= 8.1 will only support openmp-enabled versions
ln -s ${PREFIX}/bin/cp2k.${VERSION} ${PREFIX}/bin/cp2k.sopt
