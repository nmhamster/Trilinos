# This script is sourced to return all of the supported builds

export ATDM_CONFIG_CTEST_S_BUILD_NAME_PREFIX=Trilinos-atdm-

export ATDM_CONFIG_ALL_SUPPORTED_BUILDS=(
  gnu-openmp-release
  intel-openmp-release
  gnu-openmp-debug
  intel-openmp-debug
  )
