#!/bin/bash
set -ex

if [[ "${mpi}" == "openmpi" ]]; then
  CP2K_USE_ELPA="ON"
  export OMPI_ALLOW_RUN_AS_ROOT=1
  export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
  export OMPI_MCA_plm_rsh_agent=/bin/false
else
  CP2K_USE_ELPA="OFF"
fi

# Build CP2K
export PKG_CONFIG_PATH="${PREFIX}/lib:${PKG_CONFIG_PATH}"
cmake -B build -S . \
  -GNinja \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_SKIP_RPATH="ON" \
  -DCMAKE_VERBOSE_MAKEFILE="OFF" \
  -DCP2K_BLAS_VENDOR="OpenBLAS" \
  -DCP2K_USE_EVERYTHING="OFF" \
  -DCP2K_USE_ELPA="${CP2K_USE_ELPA}" \
  -DCP2K_USE_FFTW3="ON" \
  -DCP2K_USE_HDF5="ON" \
  -DCP2K_USE_LIBTORCH="ON" \
  -DCP2K_USE_LIBINT2="ON" \
  -DCP2K_USE_LIBXC="ON" \
  -DCP2K_USE_MPI="ON" \
  -DCP2K_USE_MPI_F08="ON" \
  -DCP2K_USE_PLUMED="ON" \
  -DCP2K_USE_SIRIUS="ON" \
  -DCP2K_USE_SPGLIB="ON" \
  -DCP2K_USE_SPLA="ON" \
  -DCP2K_USE_TBLITE="OFF" \
  -DCP2K_USE_TREXIO="ON"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
ln -sf cp2k.psmp "${PREFIX}/bin/cp2k.popt"
ln -sf cp2k.psmp "${PREFIX}/bin/cp2k"

# Restrict UCX to TCP (disable high-performance transports)
export UCX_TLS=self,tcp

# Run CP2K regression tests
export CP2K_DATA_DIR="${PREFIX}/share/cp2k/data"
export OMP_STACKSIZE=256M
"${PWD}/tests/do_regtest.py" "${PREFIX}/bin" "psmp" \
  --maxtasks "${CPU_COUNT}" \
  --smoketest \
  --workbasedir "${BUILD_PREFIX}"
# For a full regression test without --smoketest add
#  --skipdir "QS/regtest-dcdft-hfx" \
#  --skipdir "SIRIUS/regtest-1" \
# to make it pass without error
