#
#    U N I V E R S A L   F L A G S
#
# SRCDIR is set in makefile or on the compile line
INCDIRS := -I. -I$(SRCDIR)/prep
FLIBS   :=
IMODS   :=  -I
DA      :=  -DLINUX
DP      :=  -DLINUX -DCMPI
DPRE    :=  -DLINUX
CLIBS	  :=
MSGLIBS :=
#
#          G  F O R T R A N
#
ifeq ($(compiler),gfortran)
   PPFC     :=  gfortran
   FC       :=  gfortran
   PFC      :=  mpif90
   COMMON_FLAGS := $(INCDIRS) -ffixed-line-length-none
   DEBUG_FLAGS  := $(COMMON_FLAGS) -g -O0 -fbacktrace
   DEBUG_FULL   := $(DEBUG_FLAGS) -fbounds-check -ffpe-trap=zero,invalid,overflow,denormal -DALL_TRACE -DFLUSH_MESSAGES -DFULL_STACK -DDEBUG_HOLLAND -DDEBUG_WARN_ELEV
   FFLAGS1  :=  $(COMMON_FLAGS) -O2
   CC	    := gcc
   CCBE   := $(CC)
   CFLAGS := $(INCDIRS) -O2 -DLINUX
   ifeq ($(PROFILE),enable)
      FFLAGS1	:=  $(COMMON_FLAGS) -pg -O0 -fprofile-arcs -ftest-coverage
   endif
   ifeq ($(DEBUG),full)
      FFLAGS1	:=  $(DEBUG_FULL)
      CFLAGS := $(INCDIRS) -g -O0 -DLINUX
   endif
   ifeq ($(DEBUG),compiler-warnings)
      FFLAGS1	:=  $(DEBUG_FLAGS) -Wall -Wextra -Werror -Wall -Wextra -Wconversion -pedantic -fimplicit-none -Wuninitialized -Wsurprising -Wuse-without-only -Wimplicit-procedure -Winteger-division -Wconversion-extra -DALL_TRACE -DFLUSH_MESSAGES -DFULL_STACK
   endif
   ifeq ($(DEBUG),full-not-fpe)
      FFLAGS1	:=  $(subst "-ffpe-trap=zero,invalid,overflow,denormal",,$(DEBUG_FULL))
   endif
   # Brett Estrade: Check GCC version for -fallow-argument-mismatch flag (needed for GCC >= 10.1)
   GCC_VER_MAJOR := $(shell $(FC) -dumpversion | cut -f1 -d.)
   GCC_VER_MINOR := $(shell $(FC) -dumpversion | cut -f2 -d.)

   ifeq ($(shell test $(GCC_VER_MAJOR) -gt 10 || (test $(GCC_VER_MAJOR) -eq 10 && test $(GCC_VER_MINOR) -ge 1) && echo 1), 1)
      $(info GCC $(GCC_VER_MAJOR).$(GCC_VER_MINOR) detected - adding -fallow-argument-mismatch flag)
      FFLAGS2 += -fallow-argument-mismatch
      FFLAGS3 += -fallow-argument-mismatch
   endif
endif
#
#   I N T E L   A N D   I N T E L - O N E A P I
#
ifneq (,$(filter intel intel-oneapi,$(compiler)))
   CC   := icc
   PPFC := ifort
   FC   := ifort
   PFC  := mpiifort
   ifeq ($(filter intel-oneapi,$(compiler)),$(compiler))
      CC := icx
      ifeq ($(shell command -v mpiifx >/dev/null 2>&1 && echo yes),yes)
         PPFC := ifx
         FC   := ifx
         PFC  := mpiifx
      else ifeq ($(shell command -v mpiifort >/dev/null 2>&1 && echo yes),yes)
         PPFC := ifort
         FC   := ifort
         PFC  := mpiifort
      else
         $(error Neither mpiifx nor mpiifort was found in PATH.)
      endif
   endif
   COMMON_FLAGS  := $(INCDIRS) -traceback -assume byterecl -132 -assume buffered_io
   DEBUG_FLAGS   := $(COMMON_FLAGS) -g -O0
   DEBUG_FULL    := $(DEBUG_FLAGS) -debug all -check all -ftrapuv -fpe0 -DALL_TRACE -DFULL_STACK -DFLUSH_MESSAGES
   FFLAGS1       := $(COMMON_FLAGS) -O2
   CFLAGS        := $(INCDIRS) -O2 -m64 -mcmodel=medium -DLINUX
   CC            := icc
   CCBE		    := $(CC)
   ifeq ($(DEBUG),full)
      CFLAGS     := $(INCDIRS) -g -O0 -m64 -mcmodel=medium -DLINUX
      FFLAGS1    :=  $(DEBUG_FULL)
   endif
   ifeq ($(DEBUG),full-not-fpe)
      FFLAGS1       :=  $(subst "-ftrapuv -fpe0",,$(DEBUG_FULL))
   endif
   ifeq ($(DEBUG),buserror)
      FFLAGS1       :=  $(DEBUG_FLAGS) -DALL_TRACE -DFULL_STACK -DFLUSH_MESSAGES -check bounds
   endif
   #
   #ZC - Adding this as a warning to users to compile with the implicit array heap allocation options enabled
   ifeq ($(FC),ifort)
      ifneq ($(shell ulimit -s),unlimited)
         $(warning (WARNING) Intel compiler has been specified. The flag "--heap-arrays $(shell ulimit -s)" should be set)
         $(warning (WARNING) in both ADCIRC cmplrflags.mk FFLAGS1 and when compiling the netcdf-fortran library)
         $(warning (WARNING) using FCFLAGS to avoid potential issues with stack allocation of large implicit arrays.)
         #@jasonfleming Added to fix bus error on hatteras@renci
         FFLAGS1 := $(FFLAGS1) -heap-arrays $(shell ulimit -s)
      endif
   endif
endif
#
# finish setting up debug settings that are not compiler specific
ifeq ($(DEBUG),full-not-warnelev)
   FFLAGS1	:=  $(subst -DDEBUG_WARN_ELEV,,$(DEBUG_FULL))
endif
ifeq ($(DEBUG),trace)
   FFLAGS1       :=  $(DEBUG_FLAGS) -DALL_TRACE -DFULL_STACK -DFLUSH_MESSAGES
endif
ifeq ($(DEBUG),netcdf_trace)
   FFLAGS1       :=  $(DEBUG_FLAGS) -DNETCDF_TRACE -DFULL_STACK -DFLUSH_MESSAGES
endif
#
#      C I R C L E   C I
#
ifeq ($(compiler),circleci)
   PPFC     :=  ifx
   FC       :=  ifx
   PFC		:=  mpif90
   FFLAGS1  :=  $(INCDIRS) -O0 -132
   FFLAGS2  :=  $(FFLAGS1)
   FFLAGS3  :=  $(FFLAGS1)
   DA       :=  -DLINUX
   DP       :=  -DLINUX -DCMPI
   DPRE     :=  -DLINUX
   IMODS    :=  -I
   CC       := icx
   CCBE     := $(CC)
   CFLAGS	:= $(INCDIRS) -O0 -mcmodel=medium -DLINUX -m64
   CLIBS    :=
   LIBS		:=
   MSGLIBS	:=
endif
#
#       N E T C D F
#
HAS_NETCDF      := $(shell nf-config --prefix 2>/dev/null)
ifneq ($(HAS_NETCDF),)
   $(info NetCDF was found in '$(HAS_NETCDF)' and will be used.)
   NETCDFHOME   := $(HAS_NETCDF)
   NETCDF       := enable
   NETCDF_FLAGS := $(shell nf-config --fflags 2>/dev/null)
   NETCDF_LIBS  := $(shell nf-config --flibs 2>/dev/null)
   ifeq ($(shell nf-config --has-nc4 2>/dev/null),yes)
      NETCDF4   := enable
   endif
   ifeq ($(shell nc-config --has-zstd 2>/dev/null),yes)
      NETCDF4_COMPRESSION=enable
   endif
   ifeq ($(WDALTVAL),enable)
      DP   += -DWDVAL_NETCDF
   endif
else
   $(info NetCDF was not found and will not be used.)
endif
#
#      D A T E T I M E
#
# build datetime manually:
# cd ../thirdparty/datetime_fortran
# autoreconf -i   # generate configure script
# ./configure     # execute configure script
# make check      # build and test datetime library
#
# DATETIMEHOME set on the command line supersedes the value
# specified here
# detect/link datetime:
DATETIMEHOME    := ../thirdparty/datetime_fortran/src
HAS_DATETIME    := $(wildcard $(DATETIMEHOME)/lib/libdatetime.a)
ifneq ($(HAS_DATETIME),)
   $(info A Fortran date/time library was found in '$(DATETIMEHOME)' and will be used.)
   FFLAGS1       += -I$(DATETIMEHOME)/lib
   FLIBS         += -L$(DATETIMEHOME)/lib -ldatetime
   DATETIME      := enable
else
   $(info The Fortran date/time library was not found and will not be used.)
endif
#
#        W G R I B 2
#
# build wgrib2 manually:
# cd ../thirdparty/wgrib2
#
# If using wgrib2 from ASGS, need to also "make lib"
# and copy library and fortran module files to
# $SCRIPTDIR/opt/include and $SCRIPTDIR/opt/lib
#
# WARNING: adcswan and padcswan will not link due to
# duplicate FFT library sybols in grib2/sp_v2.0.2_d/fftpack.f
# and thirdpary/swan/fftpack51.f90
#
# WGRIB2HOME set on the command line supersedes the value
# specified here
# detect/link grib2
WGRIB2HOME      := ../thirdparty/wgrib2/install
HAS_WGRIB2      := $(wildcard $(WGRIB2HOME)/lib/libwgrib2_api.a)
ifneq ($(HAS_WGRIB2),)
   $(info The grib2 library was found in '$(WGRIB2HOME)' and will be used.)
   FFLAGS1       += -I$(WGRIB2HOME)/include
   FLIBS         += -L$(WGRIB2HOME)/lib -lwgrib2_api -lwgrib2 -ljasper -lgomp
   GRIB2         := enable
else
   $(info The grib2 library was not found and will not be used.)
endif
#
#          X D M F
#
ifneq ($(wildcard $(XDMFHOME)),)
   $(info The XDMF library was found in '$(XDMFHOME)' and will be used.)
   FLIBS         += -L${XDMFHOME}/lib64
   XDMF          := enable
else
   $(info The XDMF library was not found and will not be used.)
endif
FFLAGS2 :=  $(FFLAGS1)
FFLAGS3 :=  $(FFLAGS1)
FFLAGS4 :=  $(FFLAGS1)