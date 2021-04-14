echo "Running with mpi=$mpi"

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
