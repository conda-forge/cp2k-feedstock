#!/bin/bash
set -ex

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
