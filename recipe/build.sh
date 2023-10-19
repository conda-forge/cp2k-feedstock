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

if [[ "$mpi" == "nompi" ]]; then
 CP2K_USE_MPI=OFF
 CP2K_VERSION=ssmp
else
 CP2K_USE_MPI=ON
 CP2K_VERSION=psmp
fi
mkdir -p build
pushd build

export PKG_CONFIG_PATH=$PREFIX/lib:$PKG_CONFIG_PATH
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_FIND_FRAMEWORK=NEVER \
      -DCMAKE_FIND_APPBUNDLE=NEVER \
      -DCP2K_ENABLE_REGTESTS=ON \
      -DPython3_EXECUTABLE="$PYTHON" \
      -DCP2K_BUILD_DBCSR=ON \
      -DCP2K_USE_MPI=$CP2K_USE_MPI \
      -DCP2K_BLAS_VENDOR=OpenBLAS \
      -DCP2K_SCALAPACK_VENDOR=GENERIC \
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
    python ./tools/regtesting/do_regtest.py cmake_build_cpu ${CP2K_VERSION} --smoketest --mpiexec 'mpiexec --bind-to none -mca plm isolated' --ompthreads 1
else
    python ./tools/regtesting/do_regtest.py cmake_build_cpu ${CP2K_VERSION} --smoketest --ompthreads 2
fi
