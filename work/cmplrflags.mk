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
# compiler flags for gfortran and gcc
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
# differentiate between intel and intel-oneapi and keep
# them consistent
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
   #@jasonfleming Added to fix bus error on hatteras@renci
   ifeq ($(HEAP_ARRAYS),fix)
      FFLAGS1 := $(FFLAGS1) -heap-arrays unlimited
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
FFLAGS2 :=  $(FFLAGS1)
FFLAGS3 :=  $(FFLAGS1)
#
# Compiler Flags for CircleCI Build Server
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
# detect netcdf
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
   FFLAGS1 += $(NETCDF_FLAGS)
   FFLAGS2 += $(NETCDF_FLAGS)
   FFLAGS3 += $(NETCDF_FLAGS)
   FLIBS   += $(NETCDF_LIBS)
   ifeq ($(WDALTVAL),enable)
      DP   += -DWDVAL_NETCDF
   endif
else
   $(info NetCDF was not found and will not be used.)
endif
#
# build datetime manually:
# cd ../thirdparty/datetime_fortran
# autoreconf -i   # generate configure script
# ./configure     # execute configure script
# make check      # build and test datetime library
#
# detect/link datetime:
DATETIMEHOME    := ../thirdparty/datetime_fortran/src
HAS_DATETIME    := $(wildcard $(DATETIMEHOME)/libdatetime.a)
ifneq ($(HAS_DATETIME),)
   $(info A Fortran date/time library was found in '$(DATETIMEHOME)' and will be used.)
   FLIBS         += -ldatetime -L$(DATETIMEHOME)/lib
   DATETIME      := enable
else
   $(info The Fortran date/time library was not found and will not be used.)
endif
#
# build wgrib2 manually:
# cd ../thirdparty/wgrib2
#
# detect/link grib2
WGRIB2HOME      := ../thirdparty/wgrib2/install
HAS_WGRIB2      := $(wildcard $(WGRIB2HOME)/wgrib2)
ifneq ($(HAS_WGRIB2),)
   $(info The grib2 library was found in '$(WGRIB2HOME)' and will be used.)
   FLIBS         += -lwgrib2_api -lwgrib2 -ljasper -L$(WGRIB2HOME)
   GRIB2         := enable
else
   $(info The grib2 library was not found and will not be used.)
endif
# detect XDMF
ifneq ($(wildcard $(XDMFHOME)),)
   $(info The XDMF library was found in '$(XDMFHOME)' and will be used.)
   FLIBS         += -L${XDMFHOME}/lib64
   XDMF          := enable
else
   $(info The XDMF library was not found and will not be used.)
endif