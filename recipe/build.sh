#!/bin/bash
export FFLAGS="$FFLAGS -fallow-argument-mismatch"
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

# make
cp ${RECIPE_DIR}/${ARCH}.${VERSION} arch/${ARCH}.${VERSION}
make -j${CPU_COUNT} ARCH=${ARCH} VERSION=${VERSION}

# run regression tests
if [[ "$mpi" == "nompi" ]]; then
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 2" test
else
  # -mca plm isolated is needed to stop openmpi from looking for ssh
  # See https://github.com/open-mpi/ompi/issues/1838#issuecomment-229914599
  make ARCH=${ARCH} VERSION=${VERSION} TESTOPTS="-ompthreads 1 -mpiexec 'mpiexec --bind-to none -mca plm isolated'" test
fi

# install
cd ${SRC_DIR}
mkdir -p ${PREFIX}/bin
cp exe/${ARCH}/cp2k.${VERSION} ${PREFIX}/bin/cp2k.${VERSION}
cp exe/${ARCH}/cp2k_shell.${VERSION} ${PREFIX}/bin/cp2k_shell.${VERSION}

exe_size=`du -sh exe/${ARCH}/cp2k.${VERSION}`
echo "Executable size: $exe_size"
