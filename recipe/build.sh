#!/bin/bash
set -ex

if [[ "${mpi}" == "openmpi" ]]; then
  CP2K_USE_ELPA="ON"
  export OMPI_ALLOW_RUN_AS_ROOT=1
  export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
  export OMPI_MCA_plm_rsh_agent=/bin/false
  TARGET="$PREFIX/include/elpa_openmp/modules/modules"
  if [ -d ${TARGET} ] ; then
    echo "${TARGET} exists."
  else
    WORKDIR=$(realpath $(pwd))
    cd $(dirname ${TARGET})
    ln -s . modules
    cd ${WORKDIR}
    ls ${TARGET}
  fi
else
  CP2K_USE_ELPA="OFF"
fi

if [[ "${target_platform}" == "linux-64" ]]; then
  CP2K_USE_LIBXSMM="ON"
  CP2K_USE_PLUMED="ON"
else
  CP2K_USE_PLUMED="OFF"
  CP2K_USE_LIBXSMM="OFF"

  # Avoid trying to access /proc/self/statm on macOS
  export FFLAGS="-D__NO_STATM_ACCESS ${FFLAGS}"

  # -- Apple Silicon + GCC: -march=native expands internally
  # to -march=apple-m1 (invalid). Use -mcpu=native instead.
  sed -i.bak "s#-march=native;-mtune=native#-mcpu=native#g" cmake/CompilerConfiguration.cmake

  # fix for:
  #   CMake Error: try_run() invoked in cross-compiling mode, please set the following cache variables appropriately:
  # │ │    MPI_RUN_RESULT_CXX_libver_mpi_normal (advanced)
  # │ │    MPI_RUN_RESULT_CXX_libver_mpi_normal__TRYRUN_OUTPUT (advanced)
  # │ │ For details see $SRC_DIR/build/TryRunResults.cmake
  export MPI_RUN_RESULT_CXX_libver_mpi_normal__TRYRUN_OUTPUT=""
  export MPI_RUN_RESULT_CXX_libver_mpi_normal=0
fi


# Build CP2K
export PKG_CONFIG_PATH="${PREFIX}/lib:${PKG_CONFIG_PATH}"
cmake -B build -S . \
  ${CMAKE_ARGS} \
  -DCP2K_BLAS_VENDOR="OpenBLAS" \
  -DCP2K_USE_COSMA="ON" \
  -DCP2K_USE_EVERYTHING="OFF" \
  -DCP2K_USE_DFTD4="OFF" \
  -DCP2K_USE_ELPA="${CP2K_USE_ELPA}" \
  -DCP2K_USE_FFTW3="ON" \
  -DCP2K_USE_HDF5="ON" \
  -DCP2K_USE_LIBINT2="ON" \
  -DCP2K_USE_LIBTORCH="ON" \
  -DCP2K_USE_LIBXC="ON" \
  -DCP2K_USE_LIBXSMM="${CP2K_USE_LIBXSMM}" \
  -DCP2K_USE_MPI="ON" \
  -DCP2K_USE_MPI_F08="ON" \
  -DCP2K_USE_PLUMED="${CP2K_USE_PLUMED}" \
  -DCP2K_USE_SIRIUS="ON" \
  -DCP2K_USE_SPGLIB="ON" \
  -DCP2K_USE_SPLA="ON" \
  -DCP2K_USE_TBLITE="OFF" \
  -DCP2K_USE_TREXIO="ON" \
  -GNinja
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
ln -sf cp2k.psmp "${PREFIX}/bin/cp2k.popt"
ln -sf cp2k.psmp "${PREFIX}/bin/cp2k"

# Restrict UCX to TCP (disable high-performance transports)
export UCX_TLS=self,tcp

# Run CP2K regression tests
export CP2K_DATA_DIR="${PREFIX}/share/cp2k/data"
export OMP_STACKSIZE=256M
${PREFIX}/bin/cp2k -v
"${PWD}/tests/do_regtest.py" "${PREFIX}/bin" "psmp" \
  --maxtasks "${CPU_COUNT}" \
  --smoketest \
  --workbasedir "${BUILD_PREFIX}"
