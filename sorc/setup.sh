#!/bin/sh

# setup.sh
# Script setup.sh that sets up UVI software package

# History
# 20210914 Hai-Tien Lee - created for WCOSS2 delivery

module reset
set -x
#module use .
source ../versions/build.ver
#export ver=v1.1.0
#export envvir=prod
#export COMP=intel
export FC=ifort

# WCOSS2 environment
module load PrgEnv-intel/${PrgEnv_intel_ver:?}
module load intel/${intel_ver:?}
module load craype/${craype_ver:?}
module load cray-mpich/${cray_mpich_ver:?}
module load w3nco/${w3nco_ver:?}
module load w3emc/${w3emc_ver:?}

./build_uvi.sh
./install_uvi.sh
