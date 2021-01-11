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
# -mca plm isolated is needed to stop openmpi from looking for ssh
# See https://github.com/open-mpi/ompi/issues/1838#issuecomment-229914599
make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 1 -mpiexec 'mpiexec --bind-to none -mca plm isolated'" test

# install
cd ${SRC_DIR}
mkdir -p ${PREFIX}/bin
cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}

# Symlink cp2k.sopt for backwards compatibility of conda-forge package
# Note: cp2k >= 8.1 will only support openmp-enabled versions
ln -s ${PREFIX}/bin/cp2k.${VERSION} ${PREFIX}/bin/cp2k.sopt
