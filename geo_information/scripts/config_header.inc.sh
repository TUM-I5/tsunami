#! /bin/bash

#
# Configuration file for Tsunami input data generation
#

#  echo -e "\n*** SETTING USER VARIBLES ***"
  #All paths are relative to the working dir
  WORKINGDIR=$PWD

  #specify the grid data, by default we use the global ETOPO1 or GEBCO grid
  #http://www.ngdc.noaa.gov/mgg/global/global.html (ETOPO1)
  #https://www.bodc.ac.uk/data/online_delivery/gebco/
  ETOPO1=data/grids/ETOPO1_Ice_g_gmt4.grd
  GEBCO=data/grids/gebco_08.nc
  
  #set global grid resolution, GEBCO: 30s, ETOPO1: 1m
  # NEW: seconds are specified with 's', but 'c'
  GLOBALGRIDRESOLUTION=30c
  
  GRIDFILE=$GEBCO
  
  #where to write grids/poi/log?
  WRITEDATATO=output
  WRITETOASCII=output #(debug)

  #where should we store the plots?
  PLOTDIR=plots
  
  #directory for temporary data
  TEMPDIR=tmp

  #where is the script stored, which calculates our displacement?
  DISPLSCRIPT=scripts/tools/CalculateSeafloorDisplacement.py
  
  #which python-libraries are used?
  DISPLLIBS="$WORKINGDIR/scripts/geotools:$WORKINGDIR/scripts/geotools/datatools"
  #where is the reformat sript stored
  #  -> script refomats the output of the clawpack-okada-script to fit the gmt
  #     requiremets + an additional plot is generated
  DISPLREFORMATSCRIPT=scripts/tools/reformat.r


  # Use GMT program execution prefix on recent ubuntu systems to execute gmt tools
  GMTPREFIX=""
  test "`hostname`" == "laptop42" && GMTPREFIX="GMT "

#set environment variables
#  echo -e "\n*** setting environment variables ***"
  #export NETCDFHOME=/Users/breuera/software/gmt/netcdf-3.6.3

  if [ `hostname` == "alex" ]; then
    # special setup for alex's laptop
    export PATH=/work/breuera/software/gmt/gmt_dev/bin:$PATH
    export PATH=/home_local/breuera/software/r/R-2.14.0/bin:$PATH
  else
    TOHOKU_PAPER_PATH="../submodules/tohoku2011-paper/sources"
    export PYTHONPATH=$TOHOKU_PAPER_PATH:$PYTHONPATH
    test -e "$TOHOKU_PAPER_PATH/subfaults.py" || { echo "Tohoku scripts not found. Did you initialize the submodules?"; exit 1; }
  fi
  #export PATH=/Users/breuera/software/gmt/bin:$PATH
  export PYTHONPATH=$DISPLLIBS:$PYTHONPATH
  
#  echo "********* LIB CONFIG *********"
#  echo "  NETCDFHOME=$NETCDFHOME"
#  echo "  PATH=$PATH"
#  echo "  PYTHONPATH=$PYTHONPATH"
#  echo
