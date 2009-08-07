#!/usr/bin/env python

import sys
import os
from PIL import Image
from PIL import ImageDraw
import math


def cutOffEdges(image):
    print "Cropping Edges...",
    imageCopy = image.copy()

    #size

    xSize = image.size[0]
    ySize = image.size[1]

    #find left most frame edge

    image = image.convert("L")

    #make into matrix

    pix = image.load()

    whiteThresh = 100
	
    
    #find upper edge
    upperEdge = 0
    thisRowAllWhite = True
    
    for y in range(0, ySize):
        if not thisRowAllWhite:
	    upperEdge = y
            break
	for x in range(0, xSize):
	    if not (pix[x,y] > whiteThresh):
                thisRowAllWhite = False

    #find left edge
    leftEdge = 0
    thisColumnAllWhite = True
    
    for x in range(0, xSize):
        if not thisColumnAllWhite:
	    leftEdge = x
            break
	for y in range(0, ySize):
	    if not (pix[x,y] > whiteThresh):
                thisColumnAllWhite = False

    #find bottom edge
    bottomEdge = ySize
    thisRowAllWhite = True
    
    ry = range(0, ySize-1)
    ry.reverse()

    for y in ry:
        if not thisRowAllWhite:
	    bottomEdge = y
            break
	for x in range(0, xSize):
	    if not (pix[x,y] > whiteThresh):
                thisRowAllWhite = False

    #find right edge
    rightEdge = xSize
    thisColumnAllWhite = True

    rx = range(0, xSize-1)
    rx.reverse()

    for x in rx:
        if not thisColumnAllWhite:
	    rightEdge = x
            break
	for y in range(0, ySize):
	    if not (pix[x,y] > whiteThresh):
                thisColumnAllWhite = False
 

    print "L:", leftEdge, "U:", upperEdge, "R:", rightEdge, "B:", bottomEdge

    image = imageCopy

    image = image.crop((leftEdge, upperEdge, rightEdge, bottomEdge))
 
    return image


def getNextPanel (image, imageName, outDir, panelNum, threshdir, thresh):
    print "Finding Panel", panelNum
    imageCopy = image.copy()

    #size

    xSize = image.size[0]
    ySize = image.size[1]

    image = image.convert("L")

    #make into matrix

    pix = image.load()

    minPanelWidth = xSize/4
    minPanelHeight = ySize/4
    whiteThresh = int(thresh)
    fudgeFactor = max([ySize,xSize])/500
    d = int(threshdir) 
    print "w:", d

    if d < 0:
	bgc = 'black'
    else:
	bgc = 'white'

    upperEdge = 0 #assumes the upper edge is at 0
    leftEdge = 0 #ditto left

    #code to find the upper left corner so that you don't have to crop it first

    #find upper edge
    upperEdge = 0
    notWhiteCount = 0
    #print "Finding upper edge..."    
    for y in range(0, ySize-1):
        #print "Trying row", y
	for x in range(0, xSize-1):
	    if(x >= xSize) and (y >= ySize):
	        #print "Ran out of image at", (x,y)
		return imageCopy
	    if d*pix[x,y] < d*whiteThresh:
                notWhiteCount +=1
	#print "notWhiteCount:", notWhiteCount 
	if notWhiteCount > minPanelWidth - fudgeFactor:
	    upperEdge = y
	    break

    #find left edge
    leftEdge = 0
    notWhiteCount = 0
    #print "Finding left edge..."
    for x in range(0, xSize-1):
	#print "Trying column", x
	for y in range(upperEdge, upperEdge+minPanelHeight):
           if(x >= xSize) or (y >= ySize):
	       #print "Ran out of image at", (x,y)
	       return imageCopy
	   if d*pix[x,y] < d*whiteThresh:
               notWhiteCount += 1
	#print "notWhiteCount:", notWhiteCount 
	if notWhiteCount > minPanelHeight - fudgeFactor:
	    leftEdge = x
            break

    print "upperEdge:", upperEdge
    print "leftEdge:", leftEdge

    x = leftEdge
    
    ####### GUTTERS #############
    #go down left edge until there is a white line
    for y in range(upperEdge+(fudgeFactor), ySize - 1):
        #could this be the start of a gutter?
	if d*pix[x,y] > d*whiteThresh: #found a white pixel
	    couldBeAGutter = True #assumes that its true
	    #print "Possible horz. gutter at", y

            #checks assumtion
	    notWhiteCount = 0
            for x in range(leftEdge,leftEdge+minPanelWidth): #see if the whiteness goes in enough that it could be a gutter

		if x >= xSize-1 or y >= ySize-1:
			break
                if(x >= xSize - fudgeFactor) and (y >= ySize - fudgeFactor):
		    #print "Ran out of image at", (x,y)
		    return imageCopy
		if d*pix[x, y] < d*whiteThresh:
			notWhiteCount += 1

		#########################################################
		### I would like to bring attention to this next line ###
		#########################################################
		if notWhiteCount > fudgeFactor: ### The right side of this inequality is the gutter fudge factor
		    couldBeAGutter = False




            #if assumtion holds
	    if couldBeAGutter or (y >= ySize - fudgeFactor): #found one on the left edge or at bottom of image
		if  (y >= ySize - fudgeFactor):
	            print "Full height panel"
		#print "Got horz. gutter at", y #well sort of... ;)
		yGutterLoc = y #save this y so we can resue the variable
		y = upperEdge

		#go along top until there is a white line down
		for x in range(leftEdge, xSize-1):

		    #could this be the start of another gutter?
		    if (d*pix[x,y] > d*whiteThresh) or (x >= xSize - fudgeFactor): #found a white pixel along top or at end of picture
			couldBeAGutter = True
                        #print "Possible vert. gutter at",(x,y)
			#checks if it really could be
			notWhiteCount = 0
			for y in range(upperEdge,upperEdge+minPanelHeight):#see if the whiteness goes down
			    if d*pix[x,y] < d*whiteThresh: #it doesnt
				#print "Possible vert. gutter at", (x,y), "fails"
				notWhiteCount += 1

			    #########################################################
	             	    ### I would like to bring attention to this next line ###
		            #########################################################
			    if notWhiteCount > fudgeFactor: ### The right side of this inequality is the gutter fudge factor
		                couldBeAGutter = False
			    #else:
			        #print "Checks out", pix[x,y], "at", (x,y)

			#yep
			if couldBeAGutter or (x >= xSize - fudgeFactor): #found another or at right
			    if (x >= xSize - fudgeFactor):
                                print "Full width panel"
			    #OK so we've found another possible gutter
			    #we should check if they meet but I wont ;)
			    print "Got panel", panelNum
			    image = imageCopy
			    print "Cropping", (leftEdge,upperEdge),(x,yGutterLoc)
			    if (x - leftEdge) <= fudgeFactor or (yGutterLoc - upperEdge) <= fudgeFactor:
				#this isn't a panel it's must be some kind of artifact
				print "Found artifact at", (leftEdge,upperEdge),(x,yGutterLoc)
			        draw = ImageDraw.Draw(image)
			        draw.rectangle([leftEdge-fudgeFactor,upperEdge-fudgeFactor,x,yGutterLoc], fill = bgc)
			        draw = None
				return image
			    
                            panel = imageCopy.crop((leftEdge,upperEdge,x,yGutterLoc))#adds this panel to the list

                            #write to output file
			    path = outDir
			    fo = open(os.path.join(path, 'PanelData.txt'), "a")
                            fo.write(str(imageName) + ', ' + str(panelNum) + ', '+ str(leftEdge)+', '+str(upperEdge)+ ', '+ str(x)+', '+str(yGutterLoc)+'\n')

			    #save panel
			    print "Saving...",

                            if not os.path.isdir(outDir):
				os.mkdir(outDir)
			    newFileName = imageName.rstrip(".jpg")
			    #pageNum = newFileName[newFileName.index('-')+1:]
			    #print "Page #", pageNum
			    #issue = newFileName[:newFileName.index('-')]
			    newFileName = newFileName + "-f" + str(panelNum) + ".jpg"

			    print newFileName
                            path = outDir
			    panel.convert('RGB').save(os.path.join(path,newFileName), "JPEG")
			    draw = ImageDraw.Draw(image)
			    print "Fill Color =", max([0,255*d])
			    draw.rectangle([leftEdge-fudgeFactor,upperEdge-fudgeFactor,x,yGutterLoc], fill=bgc)
			    draw = None
			    return image

    #I guess we didn't find anything
    return image #image is now greyscale btw. return imageCopy if you want... hope you don't actually end up here


def checkAllWhite (image, imageName):
    print "Checking All White..." 
    imageCopy = image.copy()

    #size

    xSize = image.size[0]
    ySize = image.size[1]

    image = image.convert("L")

    #make into matrix

    pix = image.load()

    maxNumPanels = 4
    minPanelWidth = 300
    minPanelHeight = 400
    whiteThresh = 220

    for y in range(0,ySize):
	for x in range(0,xSize):
            if pix[x,y] < whiteThresh:
		    print "This one did not check out. You might want to have to look at it..."
		    print "Extra info:", (x,y), "Value:", pix[x,y]
		    return -1

    print "All white"
    return 0
