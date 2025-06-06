# ADCIRC
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/adcirc/adcirc/tree/main.svg?style=shield&circle-token=468312e3a9341f3a519bbdfb4df0cda07c98bd91)](https://dl.circleci.com/status-badge/redirect/gh/adcirc/adcirc/tree/main)
[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)
[![Docker Image Version (tag)](https://img.shields.io/docker/v/adcircorg/adcirc/v56.0.3?logo=docker&label=adcircorg%2Fadcirc)](https://hub.docker.com/r/adcircorg/adcirc)
[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://adcirc.github.io/adcirc/)


ADCIRC is a system of computer programs for solving time dependent, free surface circulation and transport problems in
two and three dimensions. These programs utilize the finite element method in space allowing the use of highly flexible,
unstructured grids. Typical ADCIRC applications have included:

* Prediction of storm surge and flooding
* Modeling tides and wind driven circulation
* Larval transport studies
* Near shore marine operations
* Dredging feasibility and material disposal studies

ADCIRC has been used around the world for various studies, including those conducted by the United States Army Corps of
Engineers (USACE), Federal Emergency Management Agency (FEMA), National Oceanographic and Atmospheric Administration 
(NOAA), and many others.

## Authors
* Joannes Westerink, University of Notre Dame
* Rick Luettich, University of North Carolina at Chapel Hill

### Development Group
* Brian Blanton - RENCI
* Shintaro Bunya - University of North Carolina at Chapel Hill
* Zachary Cobell - The Water Institute of the Gulf
* Clint Dawson - University of Texas at Austin
* Casey Dietrich - North Carolina State University
* Randall Kolar - University of Oklahoma at Norman
* Chris Massey - US Army Corps of Engineers Research and Development Center, Coastal and Hydraulics Laboratory

# Gallery

Louisiana ADCIRC model simulating Hurricane Katrina storm surge and waves developed by The Water Institute of the Gulf.

<img src="https://i0.wp.com/www.psc.edu/wp-content/uploads/2021/07/katrina_aws_z0_0250-scaled.jpg?resize=1080%2C448&ssl=1" alt="Hurricane Katrina Simulation" width="800"/>

ADCIRC mesh in the Chesapeake Bay area used for the FEMA Coastal Storm Surge Study

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/FEMA_Region_III_Coastal_Storm_Surge_Study_%28page_7_crop%29.jpg/1280px-FEMA_Region_III_Coastal_Storm_Surge_Study_%28page_7_crop%29.jpg" alt="ADCIRC mesh in the Chesapeake Bay area used for the FEMA Coastal Storm Surge Study" width="400"/>

# Versions

Code versions are published based on semantic versioning as of version 56. Prior to that, ADCIRC used a two level
versioning scheme, though it approximately mirrors semantic versioning. 

# Documentation

Documentation is presently undergoing upgrades, however, the main documentation locations for users are:

1. [ADCIRC documentation](https://adcirc.github.io/adcirc)
2. [ADCIRC website](https://adcirc.org)
3. [ADCIRC Wiki](https://wiki.adcirc.org/Main_Page)

Contributors are actively consolidating information from [ADCIRC website](https://adcirc.org) and [ADCIRC Wiki](https://wiki.adcirc.org/Main_Page) into [ADCIRC documentation](https://adcirc.github.io/adcirc) to provide comprehensive, up-to-date information about ADCIRC.

# Contributing

ADCIRC is an open source project and contributions are welcome. 
Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information 
on how to contribute to the project.

The high-level summary is:
1. Run `pre-commit install` to install pre-commit hooks in your development environment. Pre-commit can be installed using `pip install pre-commit`.
2. New source files should have a "*.F90" extension
3. All new code should contain Doxygen-style comments
4. Developers are encouraged to compile their code using the GCC compilers (even if this is not their typical development environment) with `-DADCIRC_DEVELOPER_MODE=ON` to ensure that the code will build in the CI environment with strict checks
5. Developers should avoid adding new variables to the `GLOBAL` module unless absolutely necessary

# Requirements
ADCIRC minimally requires a C and Fortran compiler that minimally meet the following specifications:
* C compiler: C11 standard
* Fortran compiler: Fortran 2008 standard

ADCIRC has been tested with the following compilers:
* GNU Compiler Collection (GCC)
* Intel Classic Compilers
* Intel OneAPI Compilers/IntelLLVM
* NVIDIA HPC Compilers (nvc/nvfortran)
* LLVM (clang/flang)

Additional features, including MPI parallelism and netCDF output require additional libraries:
* MPI (Message Passing Interface) - OpenMPI, MVAPICH2, Intel MPI, or other MPI implementations
* netCDF - netCDF C and Fortran libraries

# Docker Containers

To help new users get spun up quickly with the ADCIRC model, ADCIRC is provided as Linux Docker containers and pushed to DockerHub.
New images are published either when a new version is released or the main branch has changes. The DockerHub repository is 
located [here](https://hub.docker.com/r/adcircorg/adcirc). Images may be used with Docker Desktop or Singularity on x86 or ARM CPUs
on Windows, Mac, and Linux.

Images are tagged for release versions (using semantic versioning) as well as the current state of the main branch as "latest". 
By default, a release tag should be used and only use latest to try the newest version of the code. The ADCIRC Docker images are 
distributed under the same license and conditions as this repository. 

Images built for x86 systems use the IntelLLVM compiler while images build for ARM CPUs use the GCC compiler, version 14.2. The 
x86 base image is the same that is used to build ADCIRC during continuous integration testing. 

# Examples

The ADCIRC [testing repository](http://github.com/adcirc/adcirc-testsuite) doubles as a set of examples which can be used
for new users to become acquainted with the model. Since version 55, the branches are annotated with the expected
version numbers that would allow the tests to run successfully.
