#!/usr/bin/env python

import time
import threading
import sys
import os
from PIL import Image
import math
from random import random

#from pygame.locals import *

#if not pygame.font: print 'Warning, fonts disabled'
#if not pygame.mixer: print 'Warning, sound disabled'


from optparse import OptionParser


parser = OptionParser()
parser.add_option("-d", dest="imageDir",
                  help="Image Directory. Default is the current directory", default=os.path.curdir, metavar="DIR")
parser.add_option("-x", dest="thumbWidth",
		  help="Thumbnail width. Default is 20", default = 20)
parser.add_option("-o", dest="outFile",
                  help="Output file for the scatter plot. Default is ./plot.jpg", default = "plot.jpg", metavar="OUTFILE")
parser.add_option("-v", dest="view",
                  help="Opens the plot in the default image viewer when done.", default = False, action="store_true", metavar="VIEW")
parser.add_option("-s", dest="space",
                  help="Spacing factor of the thumbnails on the plot. defalut = 1", default = 1, metavar="VIEW")


(options, args) = parser.parse_args()

global ops 
ops = options
ops.thumbWidth = float(ops.thumbWidth)
ops.space = float(ops.space)

thumbsize = (20, 20)

############ Image Analysis Functions #######
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
print "Getting Images..."
pictureFileNames = os.listdir(ops.imageDir)

picturePathNames = []
for fileName in pictureFileNames:
    if (fileName.endswith(".jpg")):
	picturePathNames.append(os.path.join(ops.imageDir, fileName))
    
    

#make images strings for pygame sprites
imageStrs = []
thumbs = []
for path in picturePathNames:
    print "Making Thumbnail:", os.path.basename(path),
    if (path.endswith(".jpg")):
	im = Image.open(path)
    else:
	print "Not a valid image"
	continue
    
    #im = cutOffEdges(im)
    print "Resizing...",
    im = im.resize((ops.thumbWidth, (im.size[1]*ops.thumbWidth/im.size[0])), Image.ANTIALIAS)
    print "Converting...",
    im = im.convert("RGB")
    print "Done"
    imageStrs.append(im.tostring())
    thumbs.append(im)



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
    print "Entropy:", str(pictureEntropy)

if doAvgHue:
    pictureAvgHue = []
    for picture in picturePathNames:
        pictureAvgHue.append ( findAvgHue(picture))
    print "Hue:", str(pictureAvgHue)




###########3 Setting Up The Window #############
#pygame.init()

#window = pygame.display.set_mode((500, 500)) #makes window

#pygame.display.set_caption('Image Messarounder') #sets title

#screen = pygame.display.get_surface()


############ Classes ##########################
#class canvas(pygame.sprite.Sprite):
#    def __init__(self, imageStr, size):
#        pygame.sprite.Sprite.__init__(self) #call Sprite initializer
#        self.image = pygame.image.fromstring(imageStr, (), "RGB")
#        self.rect = self.image.get_rect()
#        self.rect.topleft = (0, 0)
#
#    def update(self, imageStr, size):
#        self.image = pygame.image.fromstring(imageStr, (), "RGB")
#        self.rect = self.image.get_rect()


############ Plot #############################
plot = Image.new("RGB", (800, 800), "black")
for thumb in thumbs:
    plot.paste(thumb, (ops.space*pictureAvgHue[thumbs.index(thumb)], ops.space*1.5*pictureBrightness[thumbs.index(thumb)]))

if ops.view:
    plot.show()

plot.save(ops.outFile)

############3 Sprites #########################

#pictures = []
#for imageStr in imageStrs:
#    pictures.append(canvas(imageStr, thumbsize))
#
#for picture in pictures:
#    picture.rect = picture.rect.move((pictureAvgHue[pictures.index(picture)], pictureBrightness[pictures.index(picture)]))
#
#allsprites = pygame.sprite.OrderedUpdates(pictures)

################ Stuff #########################

#clock = pygame.time.Clock()

#while True:
#    clock.tick(30)
    #allsprites.draw(screen)
    #pygame.display.flip()
    #print clock.get_fps()
