#!/bin/bash
set -ex

# FindMPI cannot execute its try_run() checks when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DMPI_RUN_RESULT_C_libver_mpi_normal=0 -DMPI_RUN_RESULT_C_libver_mpi_normal__TRYRUN_OUTPUT="
  CMAKE_ARGS="${CMAKE_ARGS} -DMPI_RUN_RESULT_CXX_libver_mpi_normal=0 -DMPI_RUN_RESULT_CXX_libver_mpi_normal__TRYRUN_OUTPUT="
fi

# The Release build type uses -march=native which is not supported for aarch64
if [[ "${target_platform}" == "linux-aarch64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Generic"
fi

# Build CP2K
cmake -B build -S . \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_LIBDIR:PATH="lib" \
  -DCP2K_BLAS_VENDOR="OpenBLAS" \
  -DCP2K_USE_EVERYTHING="OFF" \
  -DCP2K_USE_COSMA="ON" \
  -DCP2K_USE_DFTD4="OFF" \
  -DCP2K_USE_ELPA="ON" \
  -DCP2K_USE_FFTW3="ON" \
  -DCP2K_USE_HDF5="ON" \
  -DCP2K_USE_LIBINT2="ON" \
  -DCP2K_USE_LIBTORCH="ON" \
  -DCP2K_USE_LIBXC="ON" \
  -DCP2K_USE_LIBXS="ON" \
  -DCP2K_USE_LIBXSMM="ON" \
  -DCP2K_USE_MPI="ON" \
  -DCP2K_USE_MPI_F08="ON" \
  -DCP2K_USE_PLUMED="ON" \
  -DCP2K_USE_SIRIUS="ON" \
  -DCP2K_USE_SPGLIB="ON" \
  -DCP2K_USE_SPLA="ON" \
  -DCP2K_USE_TBLITE="OFF" \
  -DCP2K_USE_TREXIO="ON" \
  -GNinja
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

ln -sf cp2k.psmp "${PREFIX}/bin/cp2k"
