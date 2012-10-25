#!/bin/env python
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
# Create dtopo data file for deformation of sea floor due to earthquake.
# Uses the Okada model with fault parameters from one and mesh parameters from another file

import os,sys,argparse
import geoclaw.okada as okada
import subfaults

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
    
  parser.add_argument('--config', required=1,
          help="file with grid parameters;\
                required values are mx, my, xlower, xupper, ylower and yupper;\
                parameter names and values should appear on the same single line seperated by a space")
  parser.add_argument('--subfaults', required=1, help="subfault file, a lot of files can be found at http://www.usgs.gov")  
  parser.add_argument('--outputFile', required=1, help="file where the computed grid will be placed")
  
  args=parser.parse_args()
    
    
  dtopo_fname=args.outputFile
  dtopo_cfg = args.config
  dtopo_subfaults =args.subfaults

  if os.path.exists(dtopo_fname):
    print "*** Not regenerating dtopo file (already exists): %s" % dtopo_fname
  elif not(os.path.exists(dtopo_cfg)):
    print "*** Config file missing: %s" %dtopo_cfg
  elif not(os.path.exists(dtopo_subfaults)):
      print "*** Subfaults file missing: %s" %dtopo_subfaults
  else:
    faultparams=okada.getfaultparams(dtopo_cfg)
    print(faultparams)
    subfault_model=subfaults.read_subfault_model(dtopo_subfaults)
    print "Creating deformation file %s using Okada model" %dtopo_fname
    print "  with input %s" % dtopo_subfaults
    
    X,Y,dZ = subfaults.make_okada_dz(subfault_model, faultparams)
    subfaults.write_dz(dtopo_fname, X,Y,dZ)
    print "Deformation file created."
