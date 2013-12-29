#
# Configuration file for Tsunami input data generation
#

################## TSUNAMI PARAMETER ###########################
 
  #where are the points of interest/dart-stations stored?
  #format for the DARSTATIONSFILE: "lon lat dartstationname"
  #  -> the points will be converted using the projection defined below
  #  -> the points will be plotted on the overview map
  DARTSTATIONSFILE=data/poi/2011_10_05_dart_stations_gmt.txt

  #region for the plot
  PLOTREGION=130/190/0/70 #japan
  #PLOTREGION=-195/-60/-60/40 #chile

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

    #set the proejction itself
    #  -> help: http://gmt.soest.hawaii.edu/gmt/html/man/grdproject.html
    PROJECTION="m149.5/37/1:1" #cylindrical
  

  elif [ "$PROJECTIONTYPE" = "spherical" ]
    then
    #  -> if a spherical map projection is used, the selected region will reduce the
    #     temporary data. We use  an app. region, where the spherical fits in to save
    #     temporary space and computation time. If you dont care, you could use the
    #     whole global grid via the -Rg option.
    REGION=-180/180/-10/70 #japan 2011 with hawaii
    #REGION=-180/180/-90/90 #chile 2010 (complete grid)
    
    #select the spherical region relative to the projection center (epicenter) defined below
    #BATHREGIONSPH=-500000/4000000/-1500000/1500000 #japan 2011
    BATHREGIONSPH=-500000/6500000/-2500000/1500000 #japan 2011 incl. hawaii
    DISPLREGIONSPH=-500000/6500000/-2500000/1500000 #japan 2011 incl. hawaii
    #DISPLREGIONSPH=-250000/250000/-400000/400000 #japan 20011
    #BATHREGIONSPH=-13875000/1665000/-2775000/8880000 #chile 2010
    #DISPLREGIONSPH=-555000/555000/-555000/555000 #chile 2010

    PROJECTION="e142.372/38.297/1:1" #spherical (japan 2011)
    #PROJECTION="e-72.733/-35.909/1:1" #spherical (chile 2010)
  else
    echo -e "\n *** WARNING: Selected projection is not valid; select either \"cylindrical\" or \"spherical\."
  fi
  
  #projection for the plot
  #  -> help: http://gmt.soest.hawaii.edu/gmt/html/man/pscoast.html
  PLOTPROJECTION=m.14c

  #select the grid spacing (meters) of the final grid
  GRIDSPACING=500
 
  #preceding tag
  METANAME=tohoku_gebco_ucsb3_500m_hawaii
  #METANAME=chile_gebco_usgs_500m


  #parameters for the calculation of the displacement
  DISPLCONFIG=data/subfaults/2011_03_11_tohoku_15sec.cfg
  #DISPLCONFIG=data/subfaults/2010_02_27_chile_15sec.cfg  

  #which subfaults should be tranformed
  #   -> source for lots of subfault-models http://earthquake.usgs.gov/
  DISPLSUBFAULTS=data/subfaults/2011_03_11_tohoku_ucsb3.txt
  #DISPLSUBFAULTS=data/subfaults/2010_02_27_chile_usgs.txt

