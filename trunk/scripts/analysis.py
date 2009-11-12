#!/usr/bin/env python

from PIL import Image, ImageFilter
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

# To Add
# -5 or 10 level histogram
# -blur histogram

############ Image Analysis Functions #######
def findHist(picture, res):
	print "Counting Colors:", os.path.basename(picture) , '...',
	##open image
	im = Image.open(picture)

	#im.show()
	im = im.convert("L")
	
	if res == 256: return toimage(im).histogram()
	
	hist = im.histogram()
	s = int(math.ceil(256.0/(res)))	
	
	print "s:", s

	ohist =[]
	for index in range(res):
		ohist.append(0)

	for color in range(256):
		ohist[int(math.floor(color/s))] += hist[color]

	print ohist
	return ohist

def findShapes(picture, res):
	print "Counting Shapes:", os.path.basename(picture) , '...', 
	
	struct = np.array([[0,1,0],
					   [1,1,1],
					   [0,1,0]])
	
	##open image
	im = Image.open(picture)

	#im.show()
	im = im.convert("L")

	xsize, ysize = im.size
	
	if (xsize*res < 60) or (ysize*res < 60):
		print "Image to small for given resolution..."
		res = 60.0 / min([xsize, ysize])
		print "New resolution for this image:", res
		
	im = im.resize((xsize*res, ysize*res), Image.ANTIALIAS)
	xsize, ysize = im.size
	
	im = im.filter(ImageFilter.FIND_EDGES)

	im = fromimage(im)
	im = scipy.transpose(im)
	im = scipy.divide(im, 10)
	im = im *10
	##make markers
	mark = 0
	markers = np.zeros_like(im).astype('int')
	
	for x in range(xsize):
		for y in range(ysize):
			if (x%(int(xsize/30)) == 0) and (y%(int(ysize/30)) == 0):
				mark += 1
				markers[x,y] = mark
	
	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers, structure = struct)
	#toimage(water).save("sw"+ os.path.basename(picture)) #debug output
	
	##make some masks and count the size of each region
	sizecount = []
	
	marks = range(mark+1)
	for index in range(len(marks)):
		sizecount.append(0)
	
	for x in range(0,xsize):
		for y in range(0,ysize):
			sizecount[marks.index(water[x,y])] += 1
	
	##make markers based on large regions
	mark = 0
	shapes = 0
	markers = np.zeros_like(im).astype('int')
	for mark in marks:
		if sizecount[marks.index(mark)] >= (xsize/30 + ysize/30)/2:
			shapes += 1
			
	print shapes
	return shapes
	
def findColorRegions(picture, res):
	print "Counting Color Regions:", os.path.basename(picture) , '...', 
	
	struct = np.array([[0,1,0],
					   [1,1,1],
					   [0,1,0]])
	
	##open image
	im = Image.open(picture)

	#im.show()
	im = im.convert("L")

	xsize, ysize = im.size

	if (xsize*res < 60) or (ysize*res < 60):
		print "Image to small for given resolution..."
		res = 60.0 / min([xsize, ysize])
		print "New resolution for this image:", res
			
	im = im.resize((xsize*res, ysize*res),Image.ANTIALIAS)
	
	xsize, ysize = im.size
	
	im = fromimage(im)
	im = scipy.transpose(im)
	##reduce colors
	im = scipy.divide(im, 10)
	im = im *10
	
	##make markers
	mark = 0
	markers = np.zeros_like(im).astype('int')
	
	pd = 0
	opd = 0
	for x in range(xsize):
		pd = int(x/xsize*.5)
		if pd > opd: print '.',
		opd = pd
		
		for y in range(ysize):
			if (x%(int(xsize/30)) == 0) and (y%(int(ysize/30)) == 0):
				mark += 1
				markers[x,y] = mark
	##run watershed
	water = ndimage.watershed_ift(im.astype('uint8'), markers, structure = struct)

	##make some masks and count the size of each region
	sizecount = []
	
	marks = range(mark+1)
	for index in range(len(marks)):
		sizecount.append([])
	
	pd = 0
	opd = 0
	for x in range(0,xsize):
		for y in range(0,ysize):
			sizecount[marks.index(water[x,y])].append((x,y))
	
	##make markers based on large regions
	mark = 0
	shapes = 0
	markers = np.zeros_like(im).astype('int')
	for mark in marks:
		if len(sizecount[marks.index(mark)]) >= (xsize/30 + ysize/30)/2: #should be a better ratio
			shapes += 1
			
	print shapes
	return shapes
	
	
def findBrightness(picture):
	print "Calculating Brightness:", os.path.basename(picture),
	image = Image.open(picture)
	image = image.convert("L") #converts to luminence
	image = fromimage(image)
	brightness = image.mean()
	print brightness
	return brightness

def findSize(picture):
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
	print "Entropy:", os.path.basename(picture),
	im = Image.open(picture) ##PIL
	im = im.convert("L") 
	hist = im.histogram()
	en = entropy(hist)
	print en
	return en
	
def findStdDev(picture):
	print "StdDev:", os.path.basename(picture),
	im = Image.open(picture) ##PIL
	im = im.convert("RGB") 
	hist = im.histogram()
	std = np.std(hist)
	print std
	return std
	
def findVarience(picture):
	print "Varience:", os.path.basename(picture),
	im = Image.open(picture) ##PIL
	im = im.convert("L")
	im = fromimage(im) ##scipy
	var = variance(im)
	print var
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