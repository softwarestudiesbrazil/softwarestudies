#!/usr/bin/env python

import getopt, sys, os, shutil, string, time

# ca_prep - prepare directory structure for ca_analyze
# author: Sunsern Cheamanunkul
# data: 6/15/2009

# require: wget, convert, ffmpeg

ffmpeg_args = '-r 25 -sameq'

sourceSuffix = 'source'
imagesSuffix = 'images'

supportedMovieType = ['mpeg','mpg','avi','mov','m4v','mp4']
supportedImageType = ['jpg','jpeg','png','tif','tiff','bmp']

verbose = True

CAPATH = None

def usage():
    print 'USAGE: %s [OPTIONS] <project directory>'%('ca_prep.py')
    print 'OPTIONS' 
    print '\t-h,--help    \tShow this usage screen.' 
    print '\t   --url     \tDownload and create project directory from URL.'
    print '\t   --video   \tForce video mode.'
    print '\t-q           \tQuiet mode.'

# download specfic file to projectDir/source
def downloadFromUrl(projectDir,url):
    # get filename from url
    idx = url.rfind('/')
    if idx == -1:
        print 'Error: Invalid URL'
        sys.exit(1)
    filename = url[(idx+1):]

    # set target location
    target = os.path.join(projectDir, sourceSuffix)
    createDir(target)

    target = os.path.join(target,filename)

    # begin download by calling wget
    print 'Downloading %s...'%(filename)
    command = 'wget -O %s %s'%(target,url)
    if verbose:
        print command       
    else:
        command = 'wget -q -O %s %s > /dev/null'%(target,url)
    error = os.system(command)

    if (error != 0):
        print 'Error: wget'
        sys.exit(1)


# look for a video file in the source directory under projectDir
def findVideoFile(projectDir):
    targetDir = os.path.join(projectDir,sourceSuffix)
    l = os.listdir(targetDir)
    for f in l:
        abs_f = os.path.join(targetDir,f)
        if ((os.path.isfile(abs_f)) and
            (f[-3:].lower() in supportedMovieType)):
            return abs_f
    return None

def extractFrames(projectDir,videoFile,args):
    global imagesSuffix, supportedMovieType
                
    # check if images directory already exists
    imagesDir = os.path.join(projectDir,imagesSuffix)
    if os.path.isdir(imagesDir):
        print 'WARNING: "images" directory is already existed. '+\
              'extractFrames is skipped. '+\
              'Please use --redump to force extracting frames' 
        return

    createDir(imagesDir)
    target = os.path.join(imagesDir,'%8d.jpg')
    command = 'ffmpeg -y -i %s -an %s '%(videoFile,args) +\
                  '-vcodec mjpeg %s'%(target)
    if verbose:
        print command
    else:
        command = command + ' > /dev/null'
    error = os.system(command)

    if error != 0:
        print 'Error: ffmpeg'
        sys.exit(1)


def convertToJpg(projectDir):
    global imagesSuffix, supportedImageType

    # check if images directory already exists
    imagesDir = os.path.join(projectDir,imagesSuffix)
    if os.path.isdir(imagesDir):
        print 'WARNING: "images" directory is already existed. '+\
              'ConvertToJpg is skipped. '+\
              'Please use --redump to force converting frames' 
        return

    createDir(imagesDir)

    targetDir = os.path.join(projectDir,sourceSuffix)
    l = os.listdir(targetDir)
    for f in l:
        imageFile = os.path.join(targetDir,f)
        if ((os.path.isfile(imageFile)) and 
            (f.lower()[-3:] in supportedImageType)):
            targetFile = os.path.join(imagesDir,f[0:len(f)-3]+'jpg')
            command = 'convert %s %s'%(imageFile,targetFile)
            if verbose:
                print command
            error = os.system(command)
            if error != 0:
                print 'Error: convert'
                sys.exit(1)

        
def removeIllegalChar(str):
    str = str.replace(' ','_')
    str = str.replace('(','')
    str = str.replace(')','')
    return str


def createDir(dir):
    if (not os.path.isdir(dir)):
        try:
            os.makedirs(dir)
        except error:
            print 'Error: os.makedirs'
            sys.exit(1)


###########################################   


def main(arguments):

    global CAPATH
    global verbose

    url = None
    redump = None
    videoMode = False

    try:
        opts,args = getopt.getopt(arguments, 'hq', 
                                  ['video','help','redump','url='])
    except getopt.GetoptError:
        print 'Error: Illegal arguments'
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ('-h','--help'):
            usage()
            sys.exit()
        elif o in ('-q'):
            verbose = False
        elif o in ('--url'):
            url = a
        elif o in ('--video'):
            videoMode = True
        elif o in ('--redump'):
            redump = True
        else:
            assert False, "unhandled option"

    if len(args) > 1:
        print 'Error: Too many arguments'
        usage()
        sys.exit(1)
    elif len(args) < 1:
        print 'Error: Too few arguments'
        usage()
        sys.exit(1)

    projectDir = args[0].rstrip('/')

    try:
        CAPATH = os.environ['CAPATH']
    except:
        print 'ERROR: CAPATH enviroment variable not found'
        sys.exit(1)
            
    # if url is specified, create project dir 
    # and download the file
    if url != None:
        createDir(projectDir)
        downloadFromUrl(projectDir,url)
        
    # if projectDir does not exist, exit
    if not os.path.isdir(projectDir):
        print '%s not found'%projectDir
        sys.exit(1)

    # locate a supported video file in projectDir
    videoFile = findVideoFile(projectDir)
    
    # if redump, remove images directory
    if redump != None:
        imagesDir = os.path.join(projectDir,imagesSuffix)
        if os.path.isdir(imagesDir): 
            shutil.rmtree(imagesDir)

    # import configuration file
    try:
        sys.path.append(projectDir)
        import config
        for var in dir(config):
            if not var.startswith('_'):
                globals()[var] = eval('config.' + var)
    except ImportError:
	print 'WARNING: config.py not found'	
    except:
        print 'Error: importing config.py'


    # video case
    if (videoFile != None) or videoMode:
        if (videoFile != None):
            extractFrames(projectDir,videoFile,ffmpeg_args)
        else:
            convertToJpg(projectDir)

    # images case
    else:
        convertToJpg(projectDir)


if __name__ == "__main__":
    main(sys.argv[1:])
