#!/bin/bash
set -e

source ${RECIPE_DIR}/define_vars.sh

# make
cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION}

# install
cd ${SRC_DIR}
mkdir -p ${PREFIX}/bin
cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}

# Symlink cp2k.sopt for backwards compatibility of conda-forge package
# Note: cp2k >= 8.1 will only support openmp-enabled versions
if [[ "$mpi" == "nompi" ]]; then
  ln -s ${PREFIX}/bin/cp2k.${VERSION} ${PREFIX}/bin/cp2k.sopt
fi
