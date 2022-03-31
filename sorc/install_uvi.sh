#!/bin/sh
set -x
######################
# install UVI
#
#  moves the executable to the 'exec' directory
#
#########################
cd uv_index.fd
  make -f makefile_3 install
  make -f makefile_6 install
cd ../uv_uv24hr.fd
  make -f makefile install
cd ../uv_uvlist.fd
  make -f makefile install
cd ..

#===============================
