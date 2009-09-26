#!/usr/bin/env python

from PIL import Image
import numpy as np
import scipy
from scipy import ndimage
from scipy.misc.pilutil import *
from scipy.stats.distributions import *
from scipy.ndimage.measurements import *

import sys
import os
import math
import parser
import csv

from optparse import OptionParser

oparser = OptionParser()
oparser.add_option("-i", dest="imageDir",
				  help="Image Directory. Default is the current directory", default=os.path.curdir)
oparser.add_option("-t", dest="thumbWidth",
				  help="Thumbnail width. Default is 20", type = "int", default = 20)
oparser.add_option("-o", dest="outFile",
				  help="Output file for data. Default is: data.txt", default = "data.txt")
				  
(options, args) = oparser.parse_args()

global ops 
ops = options

############ Image Analysis Functions #######
def findBrightness(picture):
	print "Calculating Brightness:", os.path.basename(picture),
	image = Image.open(picture)
	print "Converting...",
	image = image.convert("L") #converts to luminence
	image = fromimage(image)
	print "Averaging...",
	brightness = image.mean()
	print "Done"
	return brightness

def findSize(picture):
	print "Counting Pixels:", picture
	image = Image.open(picture)
	size = image.size[0] * image.size[1]
	return size

def findXSize(picture):
	image = Image.open(picture)
	size = image.size[0]
	return size

def findYSize(picture):
	image = Image.open(picture)
	size = image.size[1]
	return size
  	
def findEntropy(picture):
	print "Entropy:", os.path.basename(picture)
	im = Image.open(picture) ##PIL
	im = im.convert("L") 
	hist = im.histogram()
	en = entropy(hist)
	return en
	
def findStdDev(picture):
	print "StdDev:", os.path.basename(picture)
	im = Image.open(picture) ##PIL
	im = im.convert("RGB") 
	hist = im.histogram()
	std = np.std(hist)
	return std
	
def findVarience(picture):
	print "Varience:", os.path.basename(picture)
	im = Image.open(picture) ##PIL
	im = im.convert("L")
	im = fromimage(im) ##scipy
	var = variance(im)
	return var

def findAvgHue(picture):
	print "Getting Avg Hue:", os.path.basename(picture),
	image = Image.open(picture)

	image = image.convert("RGB")
	
	image = fromimage(image)
	
	R = image[:,:,0]
	G = image[:,:,1]
	B = image[:,:,2]

	avgRed = R.mean()
	avgGreen = G.mean()
	avgBlue = B.mean()
	print "R:", avgRed, "G:", avgGreen ,"B:" ,avgBlue, "H:",

	xR = avgRed * math.cos(math.radians(60))
	yR = avgRed * math.sin(math.radians(60))

	xG = -avgGreen
	yG = 0

	xB = avgBlue * math.cos(math.radians(60))
	yB = -avgBlue * math.sin(math.radians(60))

	xH = xR + xG + xB
	yH = yR + yG + yB

	hue = math.degrees(math.atan(yH/xH))

	if hue < 0:
		hue += 360

	if xH < 0 and yH < 0:
		hue += 180

	if xH < 0 and yH > 0:
		hue -= 180

	print hue
	return hue



################ Getting Images ###################
print "Getting Images..."
allFileNames = os.listdir(ops.imageDir)
pictureFileNames = []
for name in allFileNames:
	if name.endswith(".jpg"):
		pictureFileNames.append(name)
		
print "File names:", pictureFileNames
picturePathNames = []
for fileName in pictureFileNames:
	if (fileName.endswith(".jpg")):
		picturePathNames.append(os.path.join(ops.imageDir, fileName))
	
############## Processing Images ###################
vars = "filename"

doBrightness = True
doSize = True
doXSize = True
doYSize = True
doEntropy = True
doVarience = True
doAvgHue = True
doStdDev = True

if doBrightness:
	pictureBrightness = []
	for picture in picturePathNames:
		pictureBrightness.append ( findBrightness(picture) )
	print "Brightness:", str(pictureBrightness)
	if not ("brightness" in vars[0]):
		vars += ",brightness"

if doSize:
	pictureSize = []
	for picture in picturePathNames:
		pictureSize.append ( findSize(picture))
	print "Size:", str(pictureSize)
	if "size" not in vars[0]:
		vars += ",size"

if doXSize:
	pictureXSize = []
	for picture in picturePathNames:
		pictureXSize.append ( findXSize(picture))
	print "XSize:", str(pictureXSize)
	if "xsize" not in vars[0]:
		vars += ",xsize"

if doYSize:
	pictureYSize = []
	for picture in picturePathNames:
		pictureYSize.append ( findYSize(picture))
	print "YSize:", str(pictureYSize)
	if "ysize" not in vars[0]:
		vars += ",ysize"

if doEntropy:
	pictureEntropy = []
	for picture in picturePathNames:
		pictureEntropy.append ( findEntropy(picture))
	print "Entropy:", pictureEntropy
	if "entropy" not in vars[0]:
		vars += ",entropy"
		
if doVarience:
	pictureVar = []
	for picture in picturePathNames:
		pictureVar.append ( findVarience(picture))
	print "Varience:", str(pictureVar)
	if "varience" not in vars[0]:
		vars += ",varience"
		
if doStdDev:
	pictureStdDev = []
	for picture in picturePathNames:
		pictureStdDev.append ( findStdDev(picture))
	print "Std Dev:", str(pictureStdDev)
	if "stddev" not in vars[0]:
		vars += ",stddev"
		
if doAvgHue:
	pictureAvgHue = []
	for picture in picturePathNames:
		pictureAvgHue.append ( findAvgHue(picture))
	print "Hue:", str(pictureAvgHue)
	if "hue" not in vars[0]:
		vars += ",hue"



of = open(ops.outFile, "w")

of.write(vars + "\n")
of.write("\n") #still need to do var types
for fileName in pictureFileNames:
	of.write(fileName)
	of.write(",")
	of.write(str(pictureBrightness[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureSize[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureXSize[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureYSize[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureEntropy[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureVar[pictureFileNames.index(fileName)]))
	of.write(",")
	of.write(str(pictureStdDev[pictureFileNames.index(fileName)]))
	of.write("\n")
	of.write(str(pictureAvgHue[pictureFileNames.index(fileName)]))
	of.write("\n")
	
	