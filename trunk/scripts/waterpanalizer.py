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
				  help="Image Directory. Default is the current directory", default=os.path.curdir)				  
(options, args) = oparser.parse_args()

global ops 
ops = options

############## Panelizer #########################
def panelize(picture):

	print "Panalizing:", os.path.basename(picture)
	
	##open image
	im = Image.open(picture)
	im = im.convert("L")
	xsize, ysize = im.size
	print "xSize:", xsize, "ySize:", ysize
	im = fromimage(im)
	
	##make SQUARE
	im = np.resize(im,(xsize,xsize))
	ysize = xsize
	print '!'
	
	##reduce colors
	im = im/30
	im = im *30
	toimage(im).show()
	
	##make markers
	markers = np.zeros_like(im).astype('int16')
	xm, ym = np.ogrid[0:xsize:20, 0:ysize:20]
	markers[xm, ym]= np.arange(xm.size*ym.size).reshape((xm.size,ym.size))
	toimage(markers).show()
	
	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers)
	im[xm, ym] = im[xm-1, ym-1] # remove the isolate seeds
	
	bgwc = water[1,1]
	blackbg = np.zeros_like(im).astype('uint8')
	for x in range(xsize):
		for y in range(ysize):
			if not (water[x,y] == bgwc):
				blackbg[x,y] = im[x,y]
				
	toimage(blackbg).show()
	
	im = im - blackbg
	
	toimage(im).show()
	
	
	
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
	panelize(path)
	
################ Panalizing ########################
