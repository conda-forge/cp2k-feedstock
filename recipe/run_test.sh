#!/bin/bash
set -e

source ./define_vars.sh

# run regression tests
if [[ "$mpi" == "nompi" ]]; then
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 2" test
else
  # -mca plm isolated is needed to stop openmpi from looking for ssh
  # See https://github.com/open-mpi/ompi/issues/1838#issuecomment-229914599
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 1 -mpiexec 'mpiexec --bind-to none -mca plm isolated'" test
fi
