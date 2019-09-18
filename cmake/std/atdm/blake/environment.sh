################################################################################
#
# Set up env on a Astra ATSE builds of Trilinos
# This source script gets the settings from the ATDM_CONFIG_BUILD_NAME var.
#
################################################################################

#
# Deal with compiler versions
#

if [ "$ATDM_CONFIG_COMPILER" == "DEFAULT" ] ; then
  export ATDM_CONFIG_COMPILER=GNU-7.2.0
elif [[ "$ATDM_CONFIG_COMPILER" == "INTEL-19.3"* ]]; then
    export ATDM_CONFIG_COMPILER=INTEL-19.3
elif [[ "$ATDM_CONFIG_COMPILER" == "GNU"* ]]; then
  if [[ "$ATDM_CONFIG_COMPILER" == "GNU" ]] ; then
    export ATDM_CONFIG_COMPILER=GNU-7.2.0
elif [[ "$ATDM_CONFIG_COMPILER" != "GNU-7.2.0" ]] ; then
    echo
    echo "***"
    echo "*** ERROR: GNU COMPILER=$ATDM_CONFIG_COMPILER is not supported!"
    echo "*** Only GNU compilers supported on this system are:"
    echo "***   gnu (defaults to gnu-7.2.0)"
    echo "***   gnu-7.2.0 (default)"
    echo "***"
    return
  fi
else
  echo
  echo "***"
  echo "*** ERROR: COMPILER=$ATDM_CONFIG_COMPILER is not supported!"
  echo "***"
  return
fi

#
# Allow KOKKOS_ARCH which is needed for CUDA builds
#

if [ "$ATDM_CONFIG_KOKKOS_ARCH" == "DEFAULT" ] ; then
  unset ATDM_CONFIG_KOKKOS_ARCH
fi

echo "Using Astra ATSE compiler stack $ATDM_CONFIG_COMPILER to build $ATDM_CONFIG_BUILD_TYPE code with Kokkos node type $ATDM_CONFIG_NODE_TYPE"

export ATDM_CONFIG_USE_NINJA=ON

# Get ATDM_CONFIG_NUM_CORES_ON_MACHINE for this machine
source $ATDM_SCRIPT_DIR/utils/get_num_cores_on_machine.sh

if [ "$ATDM_CONFIG_NUM_CORES_ON_MACHINE" -gt "20" ] ; then
  export ATDM_CONFIG_MAX_NUM_CORES_TO_USE=20
  # NOTE: We get links crashing if we try to use to many processes.  ToDo: We
  # should limit the number of processes that ninja uses to link instead of
  # reducing the overrall parallel build level like this.
else
  export ATDM_CONFIG_MAX_NUM_CORES_TO_USE=$ATDM_CONFIG_NUM_CORES_ON_MACHINE
fi

export ATDM_CONFIG_BUILD_COUNT=$ATDM_CONFIG_MAX_NUM_CORES_TO_USE
# NOTE: Use as many build processes and there are cores by default.

module purge

if [[ "$ATDM_CONFIG_NODE_TYPE" == "OPENMP" ]] ; then
  export ATDM_CONFIG_CTEST_PARALLEL_LEVEL=$(($ATDM_CONFIG_MAX_NUM_CORES_TO_USE/2))
  export OMP_NUM_THREADS=2
else
  export ATDM_CONFIG_CTEST_PARALLEL_LEVEL=$(($ATDM_CONFIG_MAX_NUM_CORES_TO_USE/2))
  export OMP_PROC_BIND=FALSE
  export OMP_NUM_THREADS=1
fi

if [[ "$ATDM_CONFIG_COMPILER" == "INTEL-19.3" ]]; then
  module load devpack/20190329/openmpi/4.0.1/intel/19.3.199
  module load ninja
  export LAPACK_ROOT="$MKL_ROOT/lib/intel64"
  export ATDM_CONFIG_LAPACK_LIBS="-L${MKL_ROOT}/lib/intel64;-mkl"
  export ATDM_CONFIG_BLAS_LIBS="-L${MKL_ROOT}/lib/intel64;-mkl"
  export ATDM_CONFIG_KOKKOS_ARCH=SKX
elif [[ "$ATDM_CONFIG_COMPILER" == "GNU-7.2.0" ]] ; then
  module load devpack/20171203/openmpi/2.1.2/gcc/7.2.0
  module load ninja
  export LAPACK_ROOT="${OPENBLAS_ROOT}/lib"
  export ATDM_CONFIG_LAPACK_LIBS="-L${OPENBLAS_ROOT}/lib;-lopenblas;-lgfortran;-lgomp"
  export ATDM_CONFIG_BLAS_LIBS="-L${OPENBLAS_ROOT}/lib;-lopenblas;-lgfortran;-lgomp"
  export ATDM_CONFIG_KOKKOS_ARCH=SKX
else
  echo
  echo "***"
  echo "*** ERROR: COMPILER=$ATDM_CONFIG_COMPILER is not supported!"
  echo "***"
  return
fi

if [[ "${ATDM_CONFIG_SHARED_LIBS}" == "ON" ]] ; then
  ATDM_CONFIG_TPL_LIB_EXT=so
else
  ATDM_CONFIG_TPL_LIB_EXT=a
fi

export ATDM_CONFIG_USE_HWLOC=OFF
export HWLOC_LIBS=

export BOOST_ROOT=${BOOST_ROOT}
export HDF5_ROOT=${HDF5_ROOT}
export NETCDF_ROOT=${NETCDF_ROOT}
export PNETCDF_ROOT=${PNETCDF_ROOT}

export ATDM_CONFIG_HDF5_LIBS="-L${HDF5_ROOT}/lib;${HDF5_ROOT}/lib/libhdf5_hl.a;${HDF5_ROOT}/lib/libhdf5.a;-lz;-ldl"
export ATDM_CONFIG_NETCDF_LIBS="-L${NETCDF_ROOT}/lib;-L${PNETCDF_ROOT}/lib;-L${HDF5_ROOT}/lib;${NETCDF_ROOT}/lib/libnetcdf.${ATDM_CONFIG_TPL_LIB_EXT};${PNETCDF_ROOT}/lib/libpnetcdf.${ATDM_CONFIG_TPL_LIB_EXT};${ATDM_CONFIG_HDF5_LIBS}"

# Set MPI wrappers
export MPICC=`which mpicc`
export MPICXX=`which mpicxx`
export MPIF90=`which mpif90`

export ATDM_CONFIG_MPI_PRE_FLAGS="--bind-to;none"
export ATDM_CONFIG_COMPLETED_ENV_SETUP=TRUE
