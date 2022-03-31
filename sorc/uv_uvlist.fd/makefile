SHELL=/bin/ksh
#
# If it is invoked by the command line
#	make -f makefile
# it will compile the fortran modules indicated by SRCS into the object
# modules indicated by OBJS and produce an executable named uv_uvlist.
#
# To remove all the objects but leave the executables use the command line
#	make -f makefile clean
#
# To move the executable into the exec dir
#       make -f makefile install
#
###############################################################################
# Tunable parameters:
#   FC      Fortran compiler
#   LDFLAGS Options of the loader
#   FFLAGS  Options of the compiler
#   DEBUG   Options of the compiler included for debugging
#   LIBS    List of libraries
#   CMD     Name of the executable
#

SRCS=	uv_uvlist.f indexx.f flip_field.f

OBJS=	uv_uvlist.o indexx.o flip_field.o

#FC      =  ${FC}  #use IntelFORTRAN compiler: ifort #
LDFLAGS =	      #-o -convert big_endian#
BINDIR  =  ../../exec
INC     =  ${G2_INC4}
LIBS    =  ${W3NCO_LIB4} ${W3EMC_LIB4}
CMD     =  uv_uvlist
DEBUG   =  -DDEBUG -g -traceback -check all
FFLAGS  =  -O2 -auto     #-O3 -I $(INC)#
#
# Lines from here on down should not need to be changed.  They are the
# actual rules which make uses to build uv_uvlist.
#
all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)

clean:
	-rm -f $(OBJS) *.mod $(CMD)

test:
	$(CMD) < input.txt > output.txt
	diff output.txt valid_output.txt

debug:
	FFLAGS += $(DEBUG)

install:
	-mv $(CMD) ${BINDIR}/

#=============================================
