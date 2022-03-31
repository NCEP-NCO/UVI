#!/bin/sh
set -x
######################
# clean UVI
#
#  removes the objects and executable
#
#########################
cd uv_index.fd
  make -f makefile_3 clean
  make -f makefile_6 clean
cd ../uv_uv24hr.fd
  make -f makefile clean
cd ../uv_uvlist.fd
  make -f makefile clean
cd ..

#===============================
