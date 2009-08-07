#!/usr/bin/env python

import time
import threading
import pygame
import sys
import os
from PIL import Image
from PIL import ImageDraw
import math
from panelizer import *

from pygame.locals import *

if not pygame.font: print 'Warning, fonts disabled'
if not pygame.mixer: print 'Warning, sound disabled'

thumbsize = (100,100)
imageFolder = "Images"
#outputFolder = "Panels" #please don't change this without look through the whole file

#
#if not os.path.exists(outputFolder) and os.path.isdir(outputFolder):
	#os.path.mkdir(outputFolder)

############## Functions #######################

def makeImagePath(imageName):
    return os.path.join(imageFolder, imageName)

def ezLoad(imageName):
    return pygame.image.load(makeImagePath(imageName))

def loadSprintImage(name, colorkey=None):
    if not (name.endswith('.jpg')):
	True
        #return
    try:
        image = pygame.image.load(name)
    except pygame.error, message:
        print 'Cannot load image:', name
        raise SystemExit, message
    image = image.convert()
    if colorkey is not None:
        if colorkey is -1:
	    True
            #colorkey = image.get_at((0,0))
        #image.set_colorkey(colorkey, RLEACCEL)
    return image, image.get_rect()

def input(events): 
    for event in events: 
        if event.type == QUIT: 
            sys.exit(0) 
        else: 
            True#print event 


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
pictureFileNames = os.listdir(imageFolder)

for picture in pictureFileNames:
    if not (picture.endswith(".jpg") or (picture.endswith(".JPG"))):
        print "Cannot Load:", picture
        pictureFileNames.remove(picture)
        continue
    else:
        print "Loading:", picture

picturePathNames = []
for fileName in pictureFileNames:
    picturePathNames.append(os.path.join(imageFolder, fileName))


imageStrs = []
for path in picturePathNames:
    print "Processing For Show:", os.path.basename(path)
    im = Image.open(path)
    #print "Cutting White Space"
    #im = cutOffEdges(im)
    for panelNum in range(1,5):
        print "Getting Panel", panelNum
        im = getNextPanel(im, os.path.basename(path) , panelNum)
    print "Resizing..."
    im = im.resize(thumbsize)
    print "Converting..."
    im = im.convert("RGB")
    print "Done"
    print
    imageStrs.append(im.tostring())


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


###########3 Setting Up The Window #############
#pygame.init()

window = pygame.display.set_mode((1000, 600)) #makes window

pygame.display.set_caption('Image Messarounder') #sets title

screen = pygame.display.get_surface()


############ Classes ##########################
class canvas(pygame.sprite.Sprite):
    def __init__(self, imageStr, size):
        pygame.sprite.Sprite.__init__(self) #call Sprite initializer
        self.image = pygame.image.fromstring(imageStr, thumbsize, "RGB")
        self.rect = self.image.get_rect()
        self.rect.topleft = (0, 0)

    def update(self, imageStr, size):
        self.image = pygame.image.fromstring(imageStr, thumbsize, "RGB")
        self.rect = self.image.get_rect()


############3 Sprites #########################

pictures = []
for imageStr in imageStrs:
    pictures.append(canvas(imageStr, thumbsize))

for picture in pictures:
    picture.rect = picture.rect.move( 4*pictureAvgHue[pictures.index(picture)], 2*pictureBrightness[pictures.index(picture)])

allsprites = pygame.sprite.OrderedUpdates(pictures)


################ Stuff #########################

clock = pygame.time.Clock()

while True:
    clock.tick(5)
    input(pygame.event.get())
    allsprites.draw(screen)
    pygame.display.flip()
    #print clock.get_fps()
