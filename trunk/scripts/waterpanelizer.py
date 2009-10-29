#!/usr/bin/env python

import Image
import numpy as np
import scipy
from scipy import ndimage
from scipy.misc.pilutil import *
from scipy.stats.distributions import *
from scipy.ndimage.measurements import *

import sys
import os
from PIL import Image
import math
import parser
import csv

from optparse import OptionParser


oparser = OptionParser()
oparser.add_option("-i", dest="imageDir",
				  help="Image Directory. Default is the current directory.", default=os.path.curdir)
oparser.add_option("-d", dest="outDir",
				  help="Output Directory for mask images. Default is the current directory.", default=os.path.curdir)
oparser.add_option("-r", dest="res",
				  help="Analysis resolution. Default 10", default=10, type='int')
oparser.add_option("-s", dest="scaling",
				  help="Watershed prescaling. Default 2.0", default=2, type='int')		
oparser.add_option("-m", dest="markRes",
				  help="Marker resolution. Default 30", default=30, type='int')
oparser.add_option("-v", dest="view",
				  help="Turns on image viewing", default = False, action="store_true")
oparser.add_option("-o", dest="save",
				   help="Turns on image saving", default = False, action="store_true")
oparser.add_option("-n", dest="imNum",
				  help="Number of images to run from the image directory. Default 1000", default=1000, type='int')				  
(options, args) = oparser.parse_args()

global ops 
ops = options

############## Panelizer #########################
def waterPanelize(picture):

	print "Water Panalizing:", os.path.basename(picture)
	
	struct = np.array([[0,1,0],
					   [1,1,1],
					   [0,1,0]])
	
	##open image
	im = Image.open(picture)
	imcopy = im
	#im.show()
	im = im.convert("L")
	
	xsize, ysize = im.size
	
	#prescaling
	im = im.resize((xsize*ops.scaling, ysize*ops.scaling))
	xsize, ysize = im.size
	
	print "xSize:", xsize, "ySize:", ysize

	print '!'
	
	##reduce colors
	im = scipy.divide(im, 30)
	im = im *30
	
	#transpose for scipy
	im = scipy.transpose(im)
	print "im shape:", im.shape

	
	##make markers
	mark = 0
	markers = np.zeros_like(im).astype('int')
	for x in range(xsize):
		for y in range(ysize):
			if (x%(ops.markRes) == 0) and (y%(ops.markRes) == 0):
				mark += 1
				markers[x,y] = mark
	
	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers, structure = struct)
	#water[xm, ym] = water[xm-1, ym-1] # remove the isolate seeds
	
	#make diff mask for 'gutter'
	bgwc = water[1,1] ##assumes that (1,1) is part of the gutter
	blackbg = np.zeros_like(im).astype('uint8')
	
	for x in range(xsize):
		for y in range(ysize):
			if not (water[x,y] == bgwc):
				blackbg[x,y] = im[x,y]
	
	#subtract balck bg mask
	im = im - blackbg

	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers, structure = struct) 

	
	##make some masks and count the size of each region
	sizecount = []
	masks = []
	
	marks = range(mark+1)
	for index in range(len(marks)):
		sizecount.append(0)
		masks.append([])
	
	for x in range(0,xsize,ops.res):
		print int(float(x)/xsize*100), '%'
		for y in range(0,ysize,ops.res):
			sizecount[marks.index(water[x,y])] += 1
			masks[marks.index(water[x,y])].append((x,y))
	
	##make markers based on large regions
	mark = 0
	markers = np.zeros_like(im).astype('int')
	for mark in marks:
		if sizecount[marks.index(mark)] >= 200*200/ops.res/ops.res*ops.scaling:
			markers[masks[marks.index(mark)][int(200*200/ops.res/ops.res*ops.scaling)]] = mark
			print 'panel found'
	
	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers, structure = struct) 
	
	##retranspose and postscale
	water = scipy.transpose(water)
	water = water/ops.scaling
	
	##save and view
	if ops.view: toimage(water).resize((xsize/2,ysize/2)).show()
	if ops.save: 
		print (os.path.join(ops.outDir,os.path.basename(picture)+'_mask.jpg'), "JPEG")
		toimage(water).convert('RGB').save(os.path.join(ops.outDir,os.path.basename(picture)+'_mask.jpg'), "JPEG")
		
	return os.path.join(ops.outDir,os.path.basename(picture)+'_mask.jpg'), "JPEG"
		
	
################ Getting Images ###################
print "Getting Images..."
allFileNames = os.listdir(ops.imageDir)
pictureFileNames = []
for name in allFileNames:
	if name.endswith(".jpg") or  name.endswith(".JPG"):
		pictureFileNames.append(name)
		
print "File names:", pictureFileNames
picturePathNames = []
for fileName in pictureFileNames:
	if (fileName.endswith(".jpg")):
		picturePathNames.append(os.path.join(ops.imageDir, fileName))
for path in picturePathNames:
	if picturePathNames.index(path) == ops.imNum:
		break
	waterPanelize(path)
