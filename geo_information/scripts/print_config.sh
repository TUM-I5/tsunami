#!/bin/bash


# load configuration
. ./scripts/config.inc.sh



  echo
  echo "**********************************"
  echo "********* TSUNAMI CONFIG *********"
  echo "**********************************"

  echo "  WRITEDATATO=$WRITEDATATO"
  echo "  WRITETOASCII=$WRITETOASCII"
  echo "  TEMPDIR=$TEMPDIR"
  echo "  PLOTDIR=$PLOTDIR"

  echo "  METANAME=$METANAME"
  echo
  echo "  REGION = $REGION"
  echo "  GRIDFILE = $GRIDFILE"
  echo "  GLOBALGRIDRESOLUTION = $GLOBALGRIDRESOLUTION"
  echo
  echo "  PLOTREGION = $PLOTREGION"
  echo "  PROJECTIONTYPE = $PROJECTIONTYPE"
  echo "  PROJECTION = $PROJECTION"
  echo
  echo "  GRIDSPACING = $GRIDSPACING		< grid spacing of final grid"
  echo
  echo "  BATHREGIONSPH = $BATHREGIONSPH		< region relative to displacement center"
  echo
  echo "  DISPLREFORMATSCRIPT = $DISPLREFORMATSCRIPT"
  echo "  DARTSTATIONSFILE = $DARTSTATIONSFILE"
  echo "  DISPLCONFIG = $DISPLCONFIG"
  echo "  DISPLSUBFAULTS = $DISPLSUBFAULTS"
  echo "  DISPLREGIONSPH = $DISPLREGIONSPH	< region relative to displacement center"
  echo
