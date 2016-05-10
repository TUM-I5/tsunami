#!/bin/bash
#
# @file
# This file is part of the tsunami repository.
#
# @author Alexander Breuer (breuera AT in.tum.de, http://www5.in.tum.de/wiki/index.php/Dipl.-Math._Alexander_Breuer)
#
# @section LICENSE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# @section DESCRIPTION
#
# THIS SCRIPT IS INTENDED TO BE EXECUTED FROM THE geo_information DIRECTORY!!!
#
# Input:
#        Bathymetric data files in a latitude/longitude format.
#        Subfaults.
# Output:
#        Projection of the gridded data in a specified domain
#        to a 2D grid with a pre-defined number of rows/columns 

# load configuration
. ./scripts/config.inc.sh

echo -e "*****************************"
echo -e "*** CONVERT DISPLACEMENT  ***"
echo -e "*****************************"

#compute displacement
  #2D-projection
  echo -e "\n*** generating 2D-projections ($PROJECTION) ***"
  
  #points of interest
  #   -F force 1:1 scaling
  #
  #grid projections
  #   -A force 1:1 scaling
  #   -C let projected coordinates be relative to projection center [Default is relative to lower left corner]
  #   -D set the spacing in x- and y-direction (implicit: number of grid nodes)
  #   -N select the number of grid nodes (implicit: grid spacing)

  if [ "$PROJECTIONTYPE" = "cylindrical" ]; then
    $GMTPREFIX mapproject $DARTSTATIONSFILE -R$REGION -J$PROJECTION -F -V >"$WRITEDATATO/$METANAME"_poi.txt

    $GMTPREFIX grdproject $TEMPDIR/displ.nc -J$PROJECTION -G"$TEMPDIR"/displ2.nc -A -V2
    $GMTPREFIX grdsample $TEMPDIR/displ2.nc -I$GRIDSPACING -G"$TEMPDIR"/displ3.nc
  elif [ "$PROJECTIONTYPE" = "spherical" ]; then
    $GMTPREFIX mapproject $DARTSTATIONSFILE -J$PROJECTION -C -F -R0/360/0/90 >"$WRITEDATATO/$METANAME"_poi.txt

    $GMTPREFIX grdproject $TEMPDIR/displ.nc -R$REGION -J$PROJECTION -C -A -G"$TEMPDIR"/displ2.nc -V2
    #$GMTPREFIX grdsample $TEMPDIR/displ2.nc -R$REGION -I$GRIDSPACING -R$DISPLREGIONSPH -G"$TEMPDIR"/displ3.nc
    $GMTPREFIX grdsample $TEMPDIR/displ2.nc -I$GRIDSPACING -R$DISPLREGIONSPH -G"$TEMPDIR"/displ3.nc
  else
    echo -e "\n *** WARNING: Selected projection is not valid; select either \"cylindrical\" or \"spherical\."
  fi

  $GMTPREFIX grdinfo -L2 "$TEMPDIR"/displ3.nc
  cp $TEMPDIR/displ3.nc "$WRITEDATATO/$METANAME"_displ.nc

