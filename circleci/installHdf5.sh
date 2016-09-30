#!/bin/bash

installDirectory=/home/ubuntu/adcirc-cg/work/depend

if [ ! -d $installDirectory ] ; then
    mkdir $installDirectory
fi

if [ ! -d $installDirectory/hdf5_build ] ; then
    
    #...Get the hdf5 source code
    wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz

    #...Unzip the package
    tar -xzf hdf5-1.8.17.tar.gz

    #...Configure the code
    cd hdf5-1.8.17
    ./configure --prefix=$installDirectory/hdf5_build CFLAGS="-w"

    #...Build the code using 4 processors
    make -j4

    #...Install the code to the build directory
    make install

fi

#...Create links from the building directory back to
#   the directory that is cached
sudo ln -s $installDirectory/hdf5_build/include/* /usr/include/.
sudo ln -s $installDirectory/hdf5_build/lib/* /usr/lib/.
