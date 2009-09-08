#!/usr/bin/env python

import sys
import os
from PIL import Image
from PIL import ImageDraw
import math
from panelops import *

from optparse import OptionParser


parser = OptionParser()
parser.add_option("-d", dest="imageDir",
                  help="Image Directory. Default is the current directory", default=os.path.curdir, metavar="DIR")
parser.add_option("-w", dest="threshdir",
		  help="Threshold direction. 1 for values above the threshold are background, -1 for below. Default 1", default=1)
parser.add_option("-t", dest="threshold",
		  help="Background threshold. Defalut 220", default = 220)
parser.add_option("-p", dest="maxPanels",
		  help="Maximum number of panels per image. Default = 5 (even for FA)", default=6)
parser.add_option("-o", dest="outDir",
                  help="Output Directory. Default is ./Panels", default = "Panels", metavar="OUTDIR")

(options, args) = parser.parse_args()

global ops 
ops = options


imageDir = ops.imageDir

ops.maxPanels = int(ops.maxPanels)

imageFolder = "Images"
#outputFolder = "Panels" #please don't change this without look through the whole file

#
#if not os.path.exists(outputFolder) and os.path.isdir(outputFolder):
	#os.path.mkdir(outputFolder)

############## Functions #######################

def makeImagePath(imageName):
    return os.path.join(imageFolder, imageName)

############ Image Analysis Functions ########
def findBrightness(picture):
    print "Calculating Brightness:", os.path.basename(picture),
    image = Image.open(picture)
    print "Converting...",
    image = image.convert("L") #converts to luminence
    pixels = list(image.getdata())
    print "Averaging...",
    brightness = sum(pixels) / len(pixels)
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
    True

def findAvgHue(picture):
    print "Getting Avg Hue:", os.path.basename(picture),
    image = Image.open(picture)

    image = image.convert("RGB")
    
    image = image.split()

    R = list(image[0].getdata())
    G = list(image[1].getdata())
    B = list(image[2].getdata())

    avgRed = sum(R) / len(R)
    avgGreen = sum(G) / len(G)
    avgBlue = sum(B) / len(B)

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
pictureFileNames = os.listdir(imageDir)

for picture in pictureFileNames:
    if not (picture.endswith(".jpg") or (picture.endswith(".JPG"))):
        print "Cannot Load:", picture
        pictureFileNames.remove(picture)
        continue
    else:
        print "Loading:", picture

picturePathNames = []
for fileName in pictureFileNames:
    picturePathNames.append(os.path.join(imageDir, fileName))

################# Magic Happens Here ################
imageStrs = []

#write to output file
if not os.path.isdir(ops.outDir):
    os.mkdir(ops.outDir)
fo = open(os.path.join(ops.outDir, 'PanelData.txt'), "w")
fo.write('Source, PanelNum, Left, Upper, Right, Lower\n')
fo.write('string, int, int, int, int, int\n')
fo.close()

for path in picturePathNames:
    print "Panelizing:", os.path.basename(path)
    im = Image.open(path)
    #print "Cutting White Space"
    #im = cutOffEdges(im)
    panelNum = 1
    for panelNum in range(1,ops.maxPanels+1):
        print "Getting Panel", panelNum
        im = getNextPanel(im, os.path.basename(path), ops.outDir, panelNum, ops.threshdir, ops.threshold)
    print "Done"



############## Processing Images ###################
doBrightness = True
doSize = False
doXSize = False
doYSize = False
doEntropy = True
doAvgHue = True

if doBrightness:
    pictureBrightness = []
    for picture in picturePathNames:
	pictureBrightness.append ( findBrightness(picture) )
    print "Brightness:", str(pictureBrightness)

if doSize:
    pictureSize = []
    for picture in picturePathNames:
        pictureSize.append ( findSize(picture))
    print "Size:", str(pictureSize)

if doXSize:
    pictureXSize = []
    for picture in picturePathNames:
        pictureXSize.append ( findXSize(picture))
    print "XSize:", str(pictureXSize)

if doYSize:
    pictureYSize = []
    for picture in picturePathNames:
        pictureYSize.append ( findYSize(picture))
    print "YSize:", str(pictureYSize)

if doEntropy:
    pictureEntropy = []
    for picture in picturePathNames:
        pictureEntropy.append ( findEntropy(picture))

if doAvgHue:
    pictureAvgHue = []
    for picture in picturePathNames:
        pictureAvgHue.append ( findAvgHue(picture))
    print "Hue:", str(pictureAvgHue)


#picture = []
#for picture in pictures:
#    picture.append = find(picture)



