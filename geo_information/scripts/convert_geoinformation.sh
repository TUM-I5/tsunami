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
# Input:
#        Bathymetric data files in a latitude/longitude format.
#        Subfaults.
# Output:
#        Projection of the gridded data in a specified domain
#        to a 2D grid with a pre-defined number of rows/columns 

echo "**** Runing convert script ****"
echo "PWD=$PWD"

#user variables
  echo -e "\n*** setting user varibles ***"
  #All paths are relative to the working dir
  WORKINGDIR=$PWD
  
  #specify the grid data, by default we use the global ETOPO1 or GEBCO grid
  #http://www.ngdc.noaa.gov/mgg/global/global.html (ETOPO1)
  #https://www.bodc.ac.uk/data/online_delivery/gebco/
  ETOPO1=data/grids/ETOPO1_Ice_g_gmt4.grd
  GEBCO=data/grids/gebco_08.nc
  
  #set global grid resolution, GEBCO: 30s, ETOPO1: 1m
  GLOBALGRIDRESOLUTION=30s
  
  GRIDFILE=$GEBCO
    
  #where are the points of interest/dart-stations stored?
  #format for the DARSTATIONSFILE: "lon lat dartstationname"
  #  -> the points will be converted using the projection defined below
  #  -> the points will be plotted on the overview map
  DARTSTATIONSFILE=data/poi/2011_10_05_dart_stations_gmt.txt
  
  #where to write grids/poi/log?
  WRITEDATATO=output
  WRITETOASCII=output #(debug)

  #where should we store the plots?
  PLOTDIR=plots
  
  #directory for temporary data
  TEMPDIR=tmp

  #region for the plot
  #PLOTREGION=130/190/0/70 #japan
  PLOTREGION=-195/-60/-60/40 #chile

  #set the type of the (grid-)projection
  PROJECTIONTYPE=spherical
  
  if [ "$PROJECTIONTYPE" = "cylindrical" ]
    then
    #select the region to work on
    #  -> if a cylindrical map projection is used, the selected region is equal to
    #     the spatial domain which we will project
	  #use integers only!
	  #REGION=4/16/46.5/55 #germany
	  #REGION=4/8/52/55 #north sea coast
	  REGION=130/220/0/60 #pacific
	  #REGION=139/160/29/45 #japan
	  #REGION=-96/-70/-42/-9.5 #chile
  elif [ "$PROJECTIONTYPE" = "spherical" ]
    then
    #  -> if a spherical map projection is used, the selected region will reduce the
    #     temporary data. We use  an app. region, where the spherical fits in to save
    #     temporary space and computation time. If you dont care, you could use the
    #     whole global grid via the -Rg option.
    #REGION=-180/180/-10/70 #japan 2011 with hawaii
    REGION=-180/180/-90/90 #chile 2010 (complete grid)
    
    #select the spherical region relative to the projection center (epicenter) defined below
    #BATHREGIONSPH=-500000/4000000/-1500000/1500000 #japan 2011
    #BATHREGIONSPH=-500000/6500000/-2500000/1500000 #japan 2011 incl. hawaii
    #DISPLREGIONSPH=-250000/250000/-400000/400000 #japan 20011
    BATHREGIONSPH=-13875000/1665000/-2775000/8880000 #chile 2010
    DISPLREGIONSPH=-555000/555000/-555000/555000 #chile 2010
  else
    echo -e "\n *** WARNING: Selected projection is not valid; select either \"cylindrical\" or \"spherical\."
  fi
  
  #set the proejction itself
  #  -> help: http://gmt.soest.hawaii.edu/gmt/html/man/grdproject.html
  #PROJECTION="m149.5/37/1:1" #cylindrical
  #PROJECTION="e142.372/38.297/1:1" #spherical (japan 2011)
  PROJECTION="e-72.733/-35.909/1:1" #spherical (chile 2010)
  
  #projection for the plot
  #  -> help: http://gmt.soest.hawaii.edu/gmt/html/man/pscoast.html
  PLOTPROJECTION=m.14c
  
  #select the grid spacing (meters) of the final grid
  GRIDSPACING=500
  
  #preceding tag
  #METANAME=tohoku_gebco_ucsb3_500m_hawaii
  METANAME=chile_gebco_usgs_500m
  
  #where is the script stored, which calculates our displacement?
  DISPLSCRIPT=scripts/tools/CalculateSeafloorDisplacement.py
  
  #which python-libraries are used?
  DISPLLIBS="$WORKINGDIR/scripts/geotools:$WORKINGDIR/scripts/geotools/datatools"
  
  #parameters for the calculation of the displacement
  #DISPLCONFIG=data/subfaults/2011_03_11_tohoku_15sec.cfg
  DISPLCONFIG=data/subfaults/2010_02_27_chile_15sec.cfg  

  #which subfaults should be tranformed
  #   -> source for lots of subfault-models http://earthquake.usgs.gov/
  #DISPLSUBFAULTS=data/subfaults/2011_03_11_tohoku_ucsb3.txt
  DISPLSUBFAULTS=data/subfaults/2010_02_27_chile_usgs.txt
  
  #where is the reformat sript stored
  #  -> script refomats the output of the clawpack-okada-script to fit the gmt
  #     requiremets + an additional plot is generated
  DISPLREFORMATSCRIPT=scripts/tools/reformat.r

#set environment variables
  echo -e "\n*** setting environment variables ***"
  #export NETCDFHOME=/Users/breuera/software/gmt/netcdf-3.6.3
  export PATH=/work/breuera/software/gmt/gmt_dev/bin:$PATH
  export PATH=/home_local/breuera/software/r/R-2.14.0/bin:$PATH
  #export PATH=/Users/breuera/software/gmt/bin:$PATH
  export PYTHONPATH=$DISPLLIBS:$PYTHONPATH
  
  echo "  NETCDFHOME=$NETCDFHOME"
  echo "  PATH=$PATH"
  echo "  PYTHONPATH=$PYTHONPATH"

#set full variables
  echo -e "\n*** setting full variables ***"
  GRIDFILE=$WORKINGDIR/$GRIDFILE
  DARTSTATIONSFILE=$WORKINGDIR/$DARTSTATIONSFILE
  WRITEDATATO="$WORKINGDIR/$WRITEDATATO"
  WRITETOASCII="$WORKINGDIR/$WRITETOASCII"
  TEMPDIR=$WORKINGDIR/$TEMPDIR
  PLOTDIR=$WORKINGDIR/$PLOTDIR
  DISPLSCRIPT=$WORKINGDIR/$DISPLSCRIPT
  DISPLCONFIG=$WORKINGDIR/$DISPLCONFIG
  DISPLSUBFAULTS=$WORKINGDIR/$DISPLSUBFAULTS
  DISPLREFORMATSCRIPT=$WORKINGDIR/$DISPLREFORMATSCRIPT
  echo "  GRIDFILE=$GRIDFILE"
  echo "  DARTSTATIONSFILE=$DARTSTATIONSFILE"
  echo "  WRITEDATATO=$WRITEDATATO"
  echo "  WRITETOASCII=$WRITETOASCII"
  echo "  TEMPDIR=$TEMPDIR"
  echo "  PLOTDIR=$PLOTDIR"
  echo "  DISPLSCRIPT=$DISPLSCRIPT"
  echo "  DISPLREFORMATSCRIPT=$DISPLREFORMATSCRIPT"
  echo "  DISPLCONFIG=$DISPLCONFIG"
  echo "  DISPLSUBFAULTS=$DISPLSUBFAULTS"

#print information about the bathymetry grid
  echo -e "\n*** printing grid information ***"
  grdinfo $GRIDFILE

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
  pscoast -R"$PLOTREGION" -Df -N1 -J"$PLOTPROJECTION" -Glightgrey -W -B10 -U -K > "$PLOTDIR"/"$METANAME"_overview.ps

  #add symbols
  psxy $DARTSTATIONSFILE -R"$PLOTREGION" -J"$PLOTPROJECTION" -Sd.3 -Gyellow -O -K -V >> "$PLOTDIR"/"$METANAME"_overview.ps
  #add labels
    # -Wo rectangle (debug)
    # -D displacement
    # -O overlay, no new plot
    # -F+f font size
  pstext $DARTSTATIONSFILE -R"$PLOTREGION" -J"$PLOTPROJECTION" -X.4c -F+f7 -D0/.25c -O -V >> "$PLOTDIR"/"$METANAME"_overview.ps

#compute displacement
  echo -e "\n*** computing displacement ***"
  #GeoClaw
  python $DISPLSCRIPT --config=$DISPLCONFIG\
                      --subfaults=$DISPLSUBFAULTS\
                      --outputFile=$TEMPDIR/tempDispl.xyz
  #Convert into a GMT-campatible format
    Rscript $DISPLREFORMATSCRIPT --inDisplFile=$TEMPDIR/tempDispl.xyz --outDisplFile=$TEMPDIR/tempDispl.xyz --plotFile="$PLOTDIR/$METANAME"_displ.pdf

#merge bathymetry and displacement
  #generate displacement -grd-File in the specified region
    #   -I grid spacing
    #   -N value for undefined triples
    #   -r use pixel registration (TODO: GEBCO ONLY? )
    xyz2grd $TEMPDIR/tempDispl.xyz -V -R$REGION -I"$GLOBALGRIDRESOLUTION" -G$TEMPDIR/displ.nc -N0.
    grdinfo -L2 $TEMPDIR/displ.nc
  
  #extract bathymetry data in the specified region
    grdcut $GRIDFILE -R$REGION -G$TEMPDIR/bath.nc
    grdinfo -L2 $TEMPDIR/bath.nc

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
	
	  if [ "$PROJECTIONTYPE" = "cylindrical" ]
	    then
	    mapproject $DARTSTATIONSFILE -R$REGION -J$PROJECTION -F -V >"$WRITEDATATO/$METANAME"_poi.txt
	
	    grdproject $TEMPDIR/bath.nc -J$PROJECTION -G"$TEMPDIR"/bath.nc -Ae -V2
	    grdsample $TEMPDIR/bath.nc -I$GRIDSPACING -G"$WRITEDATATO/$METANAME"_bath.nc -r
	  
	    grdproject $TEMPDIR/displ.nc -J$PROJECTION -G"$TEMPDIR"/displ.nc -Ae -V2
	    grdsample $TEMPDIR/displ.nc -I$GRIDSPACING -G"$TEMPDIR"/displ.nc -r
	  elif [ "$PROJECTIONTYPE" = "spherical" ]
	    then
	    mapproject $DARTSTATIONSFILE -J$PROJECTION -C -F -R0/360/0/90 >"$WRITEDATATO/$METANAME"_poi.txt
	    
	    grdproject $TEMPDIR/bath.nc -J$PROJECTION -C -Ae -G"$TEMPDIR"/bath.nc -V2
	    grdsample $TEMPDIR/bath.nc -I$GRIDSPACING -R$BATHREGIONSPH -G"$WRITEDATATO/$METANAME"_bath.nc -r
	    
	    grdproject $TEMPDIR/displ.nc -J$PROJECTION -C -Ae -G"$TEMPDIR"/displ.nc -V2
	    grdsample $TEMPDIR/displ.nc -I$GRIDSPACING -R$DISPLREGIONSPH -G"$TEMPDIR"/displ.nc -r
	  else
	    echo -e "\n *** WARNING: Selected projection is not valid; select either \"cylindrical\" or \"spherical\."
	  fi
	  
	  grdinfo -L2 "$WRITEDATATO/$METANAME"_bath.nc
	  grdinfo -L2 "$TEMPDIR"/displ.nc
	  
          #sum up bathymetry and displacement (this procedure is outdated and not used anymore as we do the summation within our frameworks, which is the default way for a time dependent coupling)
          #Use grdmath instead - gmtmath is for ascii date, grdmath for netcdf grids.!!
          #grdmath -V $TEMPDIR/displ.nc "$WRITEDATATO/$METANAME"_bath.nc ADD = "$WRITEDATATO/$METANAME"_displ.nc
          grdinfo -L2 $TEMPDIR/displ.nc

          cp $TEMPDIR/displ.nc "$WRITEDATATO/$METANAME"_displ.nc

          
	  
	  #generate corresponding ASCII-file (debug purposes)
	  #   -H write header (m m z)
	  #grd2xyz "$WRITEDATATO/$METANAME"_bath.nc > "$WRITETOASCII/$METANAME"_bath.xyz
	  #grd2xyz "$WRITEDATATO/$METANAME"_displ.nc > "$WRITETOASCII/$METANAME"_displ.xyz

#cleanup
  echo -e "\n*** cleaning up"
  rm $TEMPDIR/bath.nc
  rm $TEMPDIR/displ.nc
  rm $TEMPDIR/tempDispl.xyz

echo -e "\n****** complete! ******"
