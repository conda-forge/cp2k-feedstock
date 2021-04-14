#!/bin/bash
set -e

source ./define_vars.sh

# create directory structure for regtest
cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
mkdir -p exe/${ARCH}
ln -s ${PREFIX}/bin/cp2k.${VERSION} exe/${ARCH}

# run regression tests
if [[ "$mpi" == "nompi" ]]; then
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-nobuild -ompthreads 2" test
else
  # -mca plm isolated is needed to stop openmpi from looking for ssh
  # See https://github.com/open-mpi/ompi/issues/1838#issuecomment-229914599
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-nobuild -ompthreads 1 -mpiexec 'mpiexec --bind-to none -mca plm isolated'" test
fi
