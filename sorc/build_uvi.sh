#!/bin/sh
set -x
sorc_root=$PWD

#function build_dir {
#  cd ${sorc_root}/$1
#  make
#  if [ $? -ne 0 ]; then
#   echo "ERROR: build of $1 FAILED!"
#  fi
#}
#
#if [ $# -eq 0 ]; then
#   for source_dir in *.fd; do
#     build_dir $source_dir
#   done
#else
#   for source_dir in $*; do
#     build_dir $source_dir.fd
#   done
#fi
if [ $# -eq 0 ] ; then
   cd uv_index.fd
    make -f makefile_3
    make -f makefile_6
   cd ../uv_uv24hr.fd
    make -f makefile
   cd ../uv_uvlist.fd
    make -f makefile
fi
#=================================
