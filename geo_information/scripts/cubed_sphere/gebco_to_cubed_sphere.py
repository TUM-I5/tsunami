#! /usr/bin/python

#
# @autor: Martin Schreiber <schreiberx@gmail.com>
#
# Description: Script to create cubed sphere bathymetry datasets
#

import os
import sys
import math
import commands


debug_mode=False

# 0: gebco_08 (high res)
# 1: gridone (almost high res)
# 2: debug with low res data
# 3: displacement data (NOT CUBES SPHERE)

dataset = 3


if dataset == 0:
	input_file="../../../gebco/gebco_08.nc"
	output_dir="../../../gebco/cubed_sphere_gebco_08"

elif dataset == 1:
	input_file="../../../gebco/gridone.nc"
	output_dir="../../../gebco/cubed_sphere_gridone"

elif dataset == 2:
	input_file="../../../gebco/grid_lowres_5km.nc"
	output_dir="../../../gebco/cubed_sphere_lowres_5km"
	debug_mode = True

elif dataset == 3:
	input_file="/home/schreibm/repositories/tsunami_git/geo_information/output/tohoku_gebco_ucsb3_500m_hawaii_raw_displ.xyz"
	grd_file="/home/schreibm/repositories/tsunami_git/geo_information/output/tohoku_gebco_ucsb3_500m_hawaii_raw_displ.nc"
	displ_region="140/145/35/41"
	resolution="1m"
	cmd="GMT xyz2grd"
	cmd+=" "+input_file
	cmd+=" -V"
	cmd+=" -R"+displ_region
	cmd+=" -I"+resolution
	cmd+=" -G"+grd_file
	cmd+=" -N0."

	print cmd
	print "Generating "+grd_file
	os.system(cmd)

	print "DONE"
	sys.exit(1)

	output_dir="/tmp/gebco/tohoku_displ_lowres_5km"
	debug_mode = True


os.system("mkdir -p "+output_dir)

tmp_file="tmp.nc"


print "Grid info:"
cmd = "GMT grdinfo "+input_file
os.system(cmd)


def getGridSize(filename):
	cmd = "GMT grdinfo "+filename+" -C"
	o = commands.getoutput(cmd).split("\t")
	return (float(o[2]), float(o[4]))

def getGridIncAndRes(filename):
	cmd = "GMT grdinfo "+filename+" -C"
	o = commands.getoutput(cmd).split("\t")
	return (float(o[7]), float(o[8]), int(o[9]), int(o[10]))


(x_inc, y_inc, res_x, res_y) = getGridIncAndRes(input_file)


face_res=int(float(res_x)/4)
face_inc=x_inc*4.0
interpolation_parameter=""

if debug_mode:	# DEBUG
	interpolation_parameter="-Sn"


if face_res % 1:
	print "ERROR: Only even face resolutions allowed!"
	sys.exit(-1)


def output_target_info():
	print "*"*40
	print "* TARGET x/y_inc: "+str(face_inc)+", "+str(face_inc)
	print "* TARGET res_x/y: "+str(face_res)+", "+str(face_res)
	print "*"*40


output_target_info()

global_region='-180/180/-90/90'

#   T
# L F R Ba
#   Bo
subregions = {
	'left':   '-180/-90/-45/45',
	'front':  '-90/0/-45/45',
	'right':  '0/90/-45/45',
	'back':   '90/180/-45/45',
	'top':    '-180/180/45/90',
	'bottom': '-180/180/-90/-45'
}

subregions_a = [
	'front',
	'right',
	'back',
	'left',
	'top',
	'bottom'
]


source_regions = {
	'front':  '-90/0/-45/45',
	'right':  '0/90/-45/45',
	'back':   '90/180/-45/45',
	'left':   '-180/-90/-45/45',
	'top':    '-180/180/45/90',
	'bottom': '-180/180/-90/-45'
}

projection_centers={
	'front':	'-45/0',
	'right':	'45/0',
	'back':		'135/0',
	'left':		'-135/0',
	'top':		'-45/90',
	'bottom':	'-45/-90',
}


def execcmd(cmd):
	print "+"*30
	print "+ "+cmd
	print "+"*30
	if os.system(cmd) != 0:
		print "ERROR"
		sys.exit(-1)


# make colormap
execcmd("GMT makecpt -Cglobe > globe_colortable.cpt")

# output global map
#execcmd("GMT grdimage -B -V "+input_file+" -R"+global_region+" -Cglobe_colortable.cpt -Jx0.07/0.07 > global_map.ps")


res = face_res

for subregion in subregions_a:
	output_file = output_dir+"/"+subregion+".nc"
	output_file_ps = output_dir+"/vis_"+subregion+".ps"

	print
	print "+"*60
	print "| Processing subregion "+subregion
	print "+"*60

	#
	# Use gnomonic projection (center of camera at center).
	#
	# __1_____1__
	# |    /  _/
	# |   /__/
	# |a/b/
	# |//
	#
	# compute the degree of the opening angle since there's a damn blending of a circle in the output.
	# Thus we need some extra data which is afterwards cut away
	#
	# a+b = arctan(2) = 63.4349488
	#
	angle = math.atan(2)/math.pi*180.0
	padding_accurate_l=0.25
	padding_accurate_r=0.75

	#
	# GNOMONIC PROJECTION
	#
	# -J (upper case for width, lower case for scale), Map projection (see below)
	# JFlon0/lat0/horizon/width, Azimuthal Gnomonic

	if not subregion in ['top', 'bottom']:

		tmp_res = str(int(res)*2)
		execcmd("GMT grdproject -JF"+projection_centers[subregion]+'/'+str(angle)+"/1 "+interpolation_parameter+" -V -R"+source_regions[subregion]+" -N"+tmp_res+"/"+tmp_res+" "+input_file+" -G"+tmp_file)

		(size_x, size_y) = getGridSize(tmp_file)
		print "size: "+str(size_x)+", "+str(size_y)

		(tmp_x_inc, tmp_y_inc, tmp_res_x, tmp_res_y) = getGridIncAndRes(tmp_file)
		print "res: "+str(tmp_res_x)+", "+str(tmp_res_y)
		print "inc: "+str(tmp_x_inc)+", "+str(tmp_y_inc)

		#
		# we have to compute the padding based on the incremental values.
		# otherwise GMT is complaining about inaccurate stuff
		#
		padding_l=tmp_x_inc*(tmp_res_x/4)
		padding_r=1.0-tmp_x_inc*(tmp_res_x/4)

		execcmd("GMT grdcut "+tmp_file+" -R"+str(padding_l)+"/"+str(padding_r)+"/"+str(padding_l)+"/"+str(padding_r)+" -fg -G"+output_file)

	else:
		#
		# WARNING WARNING WARNING WARNING WARNING WARNING WARNING
		#   there seems to be a bug since specifying 80 degree is modified to 45
		#   and furthermore not drawing the sperical restriction
		# WARNING WARNING WARNING WARNING WARNING WARNING WARNING
		execcmd("GMT grdproject -JF"+projection_centers[subregion]+"/80/1 "+interpolation_parameter+" -V -R"+source_regions[subregion]+" -N"+str(res)+"/"+str(res)+" "+input_file+" -G"+output_file)

	(size_x, size_y) = getGridSize(output_file)
	print "size: "+str(size_x)+", "+str(size_y)

	execcmd("GMT grdimage -V -B1 -Jx"+str(15.0/size_x)+" -R0/10/0/10 -Cglobe_colortable.cpt "+output_file+" > "+output_file_ps)


os.system("rm "+tmp_file)

output_target_info()

for subregion in subregions_a:
	output_file = output_dir+"/"+subregion+".nc"

	(x_inc, y_inc, res_x, res_y) = getGridIncAndRes(output_file)

	print "Resolution of file "+output_file+": "+str(res_x)+", "+str(res_y)

