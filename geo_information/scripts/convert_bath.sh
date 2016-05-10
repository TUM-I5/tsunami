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
echo -e "*** CONVERT BATHYMETRY    ***"
echo -e "*****************************"

#plot overview of the region
  #   -Dh high precision coast line data, f: full precision
  #   -S filling/clipping water
  #   -G filling/clipping land
  #   -W draw shorelines
  #   -B map boundary annotations
  #   -K additional ps commands will follow
  #   -V verbose, progress reports
  #   -N1 draw political borders
  #   -Ia all rivers
  #   -U GMT timestamp
  echo -e "\n*** generating overview map"
  #Append 17.5c to avoid annoying warnings: "Warning: %s not a valid number and may not be decoded properly."
  $GMTPREFIX pscoast -R"$PLOTREGION" -Df -N1 -J"$PLOTPROJECTION" -Glightgrey -W -B10 -U -K > "$PLOTDIR"/"$METANAME"_overview.ps || exit 1

  #add symbols
  $GMTPREFIX psxy $DARTSTATIONSFILE -R"$PLOTREGION" -J"$PLOTPROJECTION" -Sd.3 -Gyellow -O -K -V >> "$PLOTDIR"/"$METANAME"_overview.ps || exit 1
  #add labels
    # -Wo rectangle (debug)
    # -D displacement
    # -O overlay, no new plot
    # -F+f font size
#  pstext $DARTSTATIONSFILE -R"$PLOTREGION" -J"$PLOTPROJECTION" -X.4c -F+f7 -D0/.25c -O -V >> "$PLOTDIR"/"$METANAME"_overview.ps
  $GMTPREFIX pstext $DARTSTATIONSFILE -R"$PLOTREGION" -J"$PLOTPROJECTION" -X.4c -D0/.25c -O -V >> "$PLOTDIR"/"$METANAME"_overview.ps || exit 1

  #extract bathymetry data in the specified region
  echo $GMTPREFIX grdcut $GRIDFILE -R$REGION -G$TEMPDIR/bath.nc
  if [ ! -e $TEMPDIR/bath.nc ]; then
	$GMTPREFIX grdcut $GRIDFILE -R$REGION -G$TEMPDIR/bath.nc || exit 1
  fi

  echo $GMTPREFIX grdinfo -L2 $TEMPDIR/bath.nc
  $GMTPREFIX grdinfo -L2 $TEMPDIR/bath.nc || exit 1

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
    echo "*** cylindrical projection"
    echo $GMTPREFIX grdproject $TEMPDIR/bath.nc -J$PROJECTION -G"$TEMPDIR"/bath2.nc -A -V2
    $GMTPREFIX grdproject $TEMPDIR/bath.nc -J$PROJECTION -G"$TEMPDIR"/bath2.nc -A -V2 || exit 1

    echo $GMTPREFIX grdsample $TEMPDIR/bath2.nc -I$GRIDSPACING -G"$WRITEDATATO/$METANAME"_bath.nc
    $GMTPREFIX grdsample $TEMPDIR/bath2.nc -I$GRIDSPACING -G"$WRITEDATATO/$METANAME"_bath.nc || exit 1

  elif [ "$PROJECTIONTYPE" = "spherical" ]; then
    echo "*** spherical projection"
    echo $GMTPREFIX grdproject $TEMPDIR/bath.nc -R$REGION -J$PROJECTION -C -A -G"$TEMPDIR"/bath2.nc -V2
    if [ ! -e $TEMPDIR/bath2.nc ]; then
      $GMTPREFIX grdproject $TEMPDIR/bath.nc -R$REGION -J$PROJECTION -C -A -G"$TEMPDIR"/bath2.nc -V2 || exit 1
    fi

    echo $GMTPREFIX grdsample $TEMPDIR/bath2.nc -R$REGION -I$GRIDSPACING -R$BATHREGIONSPH -G"$WRITEDATATO/$METANAME"_bath.nc
    #$GMTPREFIX grdsample $TEMPDIR/bath2.nc -R$REGION -I$GRIDSPACING -R$BATHREGIONSPH -G"$WRITEDATATO/$METANAME"_bath.nc || exit 1
    if [ ! -e "$WRITEDATATO/$METANAME"_bath.nc ]; then
      $GMTPREFIX grdsample $TEMPDIR/bath2.nc -I$GRIDSPACING -R$BATHREGIONSPH -G"$WRITEDATATO/$METANAME"_bath.nc || exit 1
    fi

  else
    echo -e "\n *** WARNING: Selected projection is not valid; select either \"cylindrical\" or \"spherical\."
  fi

  $GMTPREFIX grdinfo -L2 "$WRITEDATATO/$METANAME"_bath.nc
