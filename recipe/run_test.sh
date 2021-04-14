#!/bin/bash
set -e

echo "Runing with mpi=$mpi and blas=$blas_impl"

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  ARCH=Darwin-x86-64-conda
else
  ARCH=Linux-x86-64-conda
fi

if [[ "$mpi" == "nompi" ]]; then
 VERSION=ssmp
else
 VERSION=psmp
fi


# run regression tests
if [[ "$mpi" == "nompi" ]]; then
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 2" test
else
  # -mca plm isolated is needed to stop openmpi from looking for ssh
  # See https://github.com/open-mpi/ompi/issues/1838#issuecomment-229914599
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 1 -mpiexec 'mpiexec --bind-to none -mca plm isolated'" test
fi
