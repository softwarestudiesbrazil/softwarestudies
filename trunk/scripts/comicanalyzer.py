#!/usr/bin/env python

from analysis import *
from PIL import Image
import numpy as np
import scipy
from scipy import ndimage
from scipy.misc.pilutil import *
from scipy.stats.distributions import *
from scipy.ndimage.measurements import *

import time
import sys
import os

import math
import parser
import csv

from optparse import OptionParser


oparser = OptionParser()
oparser.add_option("-i", dest="imageDir",
				  help="Image Directory. Default is the current directory.", default=os.path.curdir)
oparser.add_option("-o", dest="outFile",
				  help="Output file name. Default is /data.txt.", default="data.txt")
oparser.add_option("-r", dest="res",
				  help= 'Shape counting resolutions. Should be a quoted space seperated list" Default is "0.1 1.0".', default="0.1 1.0", type='str')
oparser.add_option("--hres", dest="hres",
				  help= 'histogram resolutions. Default is 5.', default=5, type='int')
(options, args) = oparser.parse_args()

global ops 
ops = options
ops.res = ops.res.split()

floatres = []

for r in ops.res:
	floatres.append(float(r))

ops.res = floatres
	

################ Defs ######################
def unique(a):
    """ return the list with duplicate elements removed """
    return list(set(a))
	
def difference(a, b):
	""" return the difference of two lists """
	c = []
	for element in a:
		if element not in b:
			c.append(element)
	for element in b:
		if element not in a:
			c.append(element)
	return c
	
def intersect(a, b):
    """ return the intersection of two lists """
    return list(set(a) & set(b))

def union(a, b):
	""" return the union of two lists """
	c = a
	#return list(set(a) | set(b))
	for element in b:
		if not (element in c):
			c.append(element)
	return c

def ezDataMerge(aData):
	if not os.path.isfile(ops.outFile):
		return aData
		
	fo = open(ops.outFile, "rb")
	reader = csv.reader(fo)
	bData = []
	for row in reader:
		bData.append(row)
	
	if aData == None or aData == [] or aData == '':
		return aData
		
	if aData[0] == bData[0]:
		pass #no data field conflict
	else:
		print "Data Field Conflict:", difference(aData[0], bData[0])
		return "Error"
		
	for row in aData:
		if row not in bData:
			bData.append(row)
			
	fo.close()
	return bData
	
def dataSave(data, file):
	fo = open(ops.outFile, "wb")
	fo.write('')
	writer = csv.writer(fo)
	writer.writerows(data)
	fo.close()
	
def houghTransform(im):
    width, height = im.size
    rmax = int(round(math.sqrt(height**2 + width**2)))
    print rmax
    acc = np.zeros((rmax, 180))
    for x,y in [(x,y) for x in range(1, width) for y in range(1, height)]:
        if im.getpixel((x,y)) == 255:
            for m in range(1, 180):
                arg = (m*math.pi) / 180
                r = int(round( (x * math.cos(arg)) + (y * math.sin(arg)) ))
                if 0 < r < rmax:
                    acc[r][m] += 1
	toimage(acc).save("acc.jpg")
	exit(2)

def analyze(path):

	data = []
	#houghTransform(Image.open(path))
	ac = time.clock()
	data.append(os.path.basename(path)) #filename
	data.append(path) #path
	data.append(findSize(path)) #size  
	data.append(findXSize(path)) #width
	data.append(findYSize(path)) #height
	data.append(findAvgHue(path)) #hue
	data.append(findBrightness(path)) #brigtness
	data.append(findStdDev(path)) #stddev
	data.append(findVarience(path)) #varience
	data.append(findEntropy(path)) #entropy
	qc = time.clock()
	for r in ops.res:
		data.append(findColorRegions(path, float(r))) #shapecount
	cc = time.clock()
	for r in ops.res:
		data.append(findShapes(path,float(r)))
	sc = time.clock()
	hist = findHist(path, ops.hres)
	hc = time.clock()
	print "Quick stuff took:", ((qc-ac) + (hc-sc)), 's, Color regions took:', (cc-qc), 's, Shapes took:', (sc-cc), 's'
	for index in range(len(hist)):
		data.append(hist[index])
	return data

def recFind(path):
	files = os.listdir(path)
	imageFiles = []
	for name in files:
		name = os.path.abspath(os.path.join(path, name))
		if os.path.isdir(name):
			print "Found Dir:", os.path.basename(name)
			for image in recFind(name):
				imageFiles.append(image)
			continue
		if name.endswith(".jpg") or  name.endswith(".JPG"):
			print "Found Image:", os.path.basename(name)
			imageFiles.append(name)
	
	return imageFiles
			
################ Getting Images ###################
print "Getting Images..."

picturePathNames = recFind(ops.imageDir)


print 'Got', len(picturePathNames), 'JPEGS'

########################## Magic ######################

dataTable = [] #ram verion of data.txt
dataNames = ['filename','filepath','size','xsize','ysize','meanhue','meanbrightness',
			 'stddev','varience','entropy'] #table first row
for r in ops.res:
	dataNames.append('colorregios' + str(r))
for r in ops.res:
	dataNames.append('shapes' + str(r))
for res in range(ops.hres):
	dataNames.append("hist"+str(res))
	
print "Data Names:", dataNames
dataTypes = []
dataTable.append(dataNames)
dataTable.append(dataTypes)
dataTable = ezDataMerge(dataTable)

cycleTimes = []
for path in picturePathNames:
	startTime = time.clock()
	try:
		dataTable.append(analyze(path))
	except KeyboardInterrupt:
		print
		exit(0)
	except:
		print
		print "Error:", sys.exc_info()
		print
		dataTable.append([os.path.basename(path), path, "Error", sys.exc_info()])
		
	if not dataTable == "Error":
		dataSave(dataTable, ops.outFile)
	else:
		print "Aborted"
		exit(1)
		
	endTime = time.clock()
	thisTime = endTime-startTime
	
	if(thisTime > 1): #weird, sometimes thisTime will be this really large neg. number for one or two cycles randomly
		cycleTimes.append(thisTime)
	else:
		cycleTimes.append(avgTime)
		
	totalTime = sum(cycleTimes)
	avgTime = totalTime/len(cycleTimes)
	print "This cycle:", int(thisTime), "s Average Cycle:", int(avgTime), "s Run Time:", int(totalTime/60), "m"
	print "Cycles completed:", len(cycleTimes), "Cycles to go:", (len(picturePathNames) - len(cycleTimes))
	print "Time Till Completion:", int((avgTime*len(picturePathNames)/60)-totalTime/60), 'm'
	print
	


















