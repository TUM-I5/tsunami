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


#compute displacement
  echo -e "\n*** computing displacement ***"
  test -e "$DISPLSUBFAULTS" || { echo "Subfault file not available '$DISPLSUBFAULTS'"; exit 1; }

  #GeoClaw
  python $DISPLSCRIPT --config=$DISPLCONFIG\
                      --subfaults=$DISPLSUBFAULTS\
                      --outputFile=$TEMPDIR/tempDispl.xyz

  #Convert into a GMT-campatible format
  Rscript $DISPLREFORMATSCRIPT --inDisplFile=$TEMPDIR/tempDispl.xyz --outDisplFile=$TEMPDIR/tempDispl.xyz --plotFile="$PLOTDIR/$METANAME"_displ.pdf

  #backup displacmenet data for additional postprocessing (e.g. cubed sphere)
    cp $TEMPDIR/tempDispl.xyz "$WRITEDATATO/$METANAME"_raw_displ.xyz

  #merge bathymetry and displacement
  #generate displacement -grd-File in the specified region
  #   -I grid spacing
  #   -N value for undefined triples
  #   -r use pixel registration (TODO: GEBCO ONLY? )
  CMD="$GMTPREFIX xyz2grd $TEMPDIR/tempDispl.xyz -V -R$REGION -I$GLOBALGRIDRESOLUTION -G$TEMPDIR/displ.nc -N0."
  echo "$CMD"
  $CMD

  echo "$GMTPREFIX grdinfo -L2 $TEMPDIR/displ.nc"
  $GMTPREFIX grdinfo -L2 $TEMPDIR/displ.nc

