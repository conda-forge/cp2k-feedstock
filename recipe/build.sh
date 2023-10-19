#!/bin/bash -x
set -e

echo "Runing with mpi=$mpi and blas=$blas_impl"

mkdir -p exts/dbcsr/.git

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  ARCH=Darwin-x86-64-conda
else
  ARCH=Linux-x86-64-conda
fi

if [[ "$blas_impl" == "mkl" ]]; then
    BLAS_VENDOR="MKL"
    SCALAPACK_VENDOR="MKL"
else
    BLAS_VENDOR="OpenBLAS"
    SCALAPACK_VENDOR="GENERIC"
fi
if [[ "$mpi" == "nompi" ]]; then
 CP2K_USE_MPI=OFF
 CP2K_VERSION=ssmp
else
 CP2K_USE_MPI=ON
 CP2K_VERSION=psmp
fi

export PKG_CONFIG_PATH=$PREFIX/lib:$PKG_CONFIG_PATH

mkdir -p build_dbcsr
pushd build_dbcsr

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_FIND_FRAMEWORK=NEVER \
      -DCMAKE_FIND_APPBUNDLE=NEVER \
      -DUSE_MPI=$CP2K_USE_MPI \
      -DUSE_SMM=libxsmm \
      ${CMAKE_ARGS} \
      ../exts/dbcsr

cmake --build . --config Release -j 2
make install

popd #build_dbcsr

mkdir -p build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_FIND_FRAMEWORK=NEVER \
      -DCMAKE_FIND_APPBUNDLE=NEVER \
      -DCP2K_ENABLE_REGTESTS=ON \
      -DPython3_EXECUTABLE="$PYTHON" \
      -DCP2K_BUILD_DBCSR=OFF \
      -DCP2K_USE_MPI=$CP2K_USE_MPI \
      -DCP2K_BLAS_VENDOR=$BLAS_VENDOR \
      -DCP2K_SCALAPACK_VENDOR=$SCALAPACK_VENDOR \
      -DCP2K_USE_FFTW3=ON \
      -DCP2K_USE_LIBXC=ON \
      -DCP2K_USE_LIBINT2=ON \
      -DCP2K_USE_LIBXSMM=ON \
      ${CMAKE_ARGS} \
      ..

cmake --build . --config Release -j 2

make install
popd

# run regression tests
export CP2K_DATA_DIR=$PWD/data

if [ "$CP2K_USE_MPI" == "ON" ]
then
    python ./tests/do_regtest.py local ${CP2K_VERSION} --smoketest --mpiexec 'mpiexec --bind-to none -mca plm isolated' --ompthreads 1
else
    python ./tests/do_regtest.py local ${CP2K_VERSION} --smoketest --ompthreads 2
fi
