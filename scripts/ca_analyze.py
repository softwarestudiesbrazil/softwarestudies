#!/usr/bin/env python

import getopt, sys, os, shutil, string, time

# ca_analyze - analyze images
# author: Sunsern Cheamanunkul
# data: 6/15/2009

# require: wget, convert, ffmpeg, matlab

mode = 'video'
samplingRate = 10

line_enable = True
shot_enable = True
color_enable = True
matlab_enable = True

line_args = '--preset high'
shot_args = ''
color_args = '-q 2'

imagesSuffix = 'images'
lineSuffix = 'lines'
sampleSuffix = 'samples'
shotSuffix = 'shots'
colorSuffix = 'colors'
statsSuffix = 'stats'
keyframeSuffix = 'keyframes'

procTimeFilename = 'procTime.log'

CAPATH = None

def usage():
    print 'USAGE: %s [OPTIONS] <project directory>'%('ca_analyze.py')
    print 'OPTIONS' 
    print '\t-h,--help    \tShow this usage screen.' 
    print '\t-m,--mode [video|images]\tMode of analysis. Default: video'


def createDir(dir):
    if (not os.path.isdir(dir)):
        try:
            os.makedirs(dir)
        except error:
            print 'Error: os.makedirs'
            sys.exit(1)


#########################################


def process(targetDir, command):
    
    # remove targetDir if already exist
    if os.path.isdir(targetDir):
        shutil.rmtree(targetDir)

    # create new targetDir
    createDir(targetDir)
    
    # execute command (PUT WRAPPER HERE)
    print command
    error = os.system(command)
    
    return error


#########################################

    
def processColor(projectDir, args):

    print 'Processing color...'
    
    scriptsDir = os.path.join(CAPATH,'scripts')
    sourceDir = os.path.join(projectDir,imagesSuffix)
    targetDir = os.path.join(projectDir,colorSuffix)
    
    command = '%s/color %s %s '%(scriptsDir,args,sourceDir)
    
    error = process(targetDir, command)

    if error != 0:
        print 'Error: color'
        return False

    # move output
    l = os.listdir(sourceDir)
    for f in l:
        if (f[-3:] == 'txt'):
            src = os.path.join(sourceDir,f)
            dst = os.path.join(targetDir,f)
            shutil.move(src,dst)
        
    return True


def processLine(projectDir, args):

    print 'Processing line...'

    scriptsDir = os.path.join(CAPATH,'scripts')
    sourceDir = os.path.join(projectDir,imagesSuffix)
    targetDir = os.path.join(projectDir,lineSuffix)

    command = '%s/line -d %s %s %s'\
        %(scriptsDir,targetDir,args,sourceDir)

    error = process(targetDir,command)

    if error != 0:
        print 'Error: line'
        return False

    return True


def processShot(projectDir, args):

    print 'Processing shot...'

    scriptsDir = os.path.join(CAPATH,'scripts') 
    sourceDir = os.path.join(projectDir,imagesSuffix)
    targetDir = os.path.join(projectDir,shotSuffix)

    command = '%s/shot %s %s'%(scriptsDir,args,sourceDir)
    
    error = process(targetDir,command)

    if error != 0:
        print 'Error: shot'
        return False

    # move the output file
    shotFileSrc = os.path.join(sourceDir,'shot.output.txt')
    shotFileDst = os.path.join(targetDir,'shot.output.txt')
    shutil.move(shotFileSrc,shotFileDst)

    # create keyframe dir
    keyframeDir = os.path.join(targetDir,keyframeSuffix)
    createDir(keyframeDir)
    f = open(shotFileDst,'r')
    for line in f.readlines():
        tokens = line.rstrip('\n')
        tokens = tokens.split(',')
        if (len(tokens) == 3  and tokens[1] == '1'):
            img = os.path.join(sourceDir,tokens[0])
            shutil.copy2(img,keyframeDir)            
    f.close()
    return True



def processColorTexture(projectDir):

    print 'Processing colorTexture...'

    matlabPath = os.path.join(CAPATH,'matlab')
    matlabPath = os.path.join(matlabPath,'colorTexture')
    sourceDir = os.path.join(projectDir,imagesSuffix)
    sourceDir = os.path.abspath(sourceDir).rstrip('/') + '/'
    targetDir = os.path.join(projectDir,statsSuffix)

    command = 'matlab -nodisplay -nojvm '+\
        '-r "path(path,\'%s\'); '%(matlabPath) +\
        'batch(\'%s\'); '%(sourceDir)+\
        'exit;"'

    error = process(targetDir,command)

    if error != 0:
	print 'Error: colorTexture'
	return False
    
    # move stats.txt to
    statsFile = os.path.join(sourceDir,'stats.txt')
    shutil.move(statsFile,targetDir)
    
    return True


  
def sampleFromImages(projectDir):
    sampleDir = os.path.join(projectDir,sampleSuffix)

    # remove old directory
    if os.path.isdir(sampleDir):
        shutil.rmtree(sampleDir)

    # create new one
    createDir(sampleDir)

    imagesDir = os.path.join(projectDir,imagesSuffix)
    l = os.listdir(imagesDir)
    l.sort()
    for f in l[::samplingRate]:
        shutil.copy2(os.path.join(imagesDir,f),sampleDir)



def combineResults(target, sourceFiles):
	fout = open(target,'w')
	f = []
	# open files
	for i in range(0,len(sourceFiles)):
		new_f = open(sourceFiles[i],'r')
		f.append(new_f)

	# for each line
	if (f != []):
		for line in f[0].readlines():
			fout.write(line.rstrip('\n'))
			for j in range(1,len(sourceFiles)):
				temp = f[j].readline().rstrip('\n')
	        	        temp = temp.split(',')
				temp = string.join(temp[1:],',')
				fout.write(',' + temp)
		 	fout.write('\n')
	
	# close files
	for i in range(0,len(sourceFiles)):
		f[i].close()

	fout.close()


#########################################


def main(arguments):

    global CAPATH
    global mode

    try:
        opts,args = getopt.getopt(arguments, 'hm:', 
                                  ['mode=','help'])
    except getopt.GetoptError:
        print 'Error: Illegal arguments'
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ('-h','--help'):
            usage()
            sys.exit()
        elif o in ('-m','--mode'):
            mode = a.lower()
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

    # check mode
    if not mode in ('video','images'):
        print 'unknown mode %s'%mode
        sys.exit(1)
                    
    # if projectDir does not exist, exit
    if not os.path.isdir(projectDir):
        print '%s not found'%projectDir
        sys.exit(1)

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


    shotFlag = False
    lineFlag = False
    colorFlag = False
    matlabFlag = False

    # video case
    if (mode == 'video'):

        procTimeLog = open(os.path.join(projectDir,procTimeFilename),'w')
        procTimeLog.write('shot(ms)\t')
        procTimeLog.write('color(ms)\t')
        procTimeLog.write('matlab(ms)\n')

        t1 = time.time()
        if shot_enable:
            shotFlag = processShot(projectDir,shot_args)
        t2 = time.time()
        procTimeLog.write('%0.3f\t'%((t2-t1)*1000.0))
        
        t1 = time.time()
        if color_enable:
            colorFlag = processColor(projectDir,color_args)
        t2 = time.time()
        procTimeLog.write('%0.3f\t'%((t2-t1)*1000.0))

        t1 = time.time()
        if matlab_enable:
            matlabFlag = processColorTexture(projectDir)
        t2 = time.time()
        procTimeLog.write('%0.3f\n'%((t2-t1)*1000.0))
	
        procTimeLog.close()

	# check for finished results 	
	files = []
        if shotFlag:
	     	files.append(projectDir+'/shots/shot.output.txt')
	if matlabFlag:
	     	files.append(projectDir+'/stats/stats.txt')

        combineResults(projectDir+'/result.txt',files)

    # images case
    elif (mode == 'images'):

        sampleFromImages(projectDir)

        procTimeLog = open(os.path.join(projectDir,procTimeFilename),'w')
        procTimeLog.write('line(ms)\t')
        procTimeLog.write('color(ms)\t')
        procTimeLog.write('matlab(ms)\n')
        
        t1 = time.time()
        if line_enable:
            lineFlag = processLine(projectDir,line_args)
        t2 = time.time()
        procTimeLog.write('%0.3f\t'%((t2-t1)*1000.0))

        t1 = time.time()
        if color_enable:
            colorFlag = processColor(projectDir,color_args)
        t2 = time.time()
        procTimeLog.write('%0.3f\t'%((t2-t1)*1000.0))

        t1 = time.time()
        if matlab_enable:
            matlabFlag = processColorTexture(projectDir)
        t2 = time.time()
        procTimeLog.write('%0.3f\t'%((t2-t1)*1000.0))
 
        procTimeLog.close()

	# check for finished results 	
	files = []
	if lineFlag:
	     	files.append(projectDir+'/lines/result.txt')
	if matlabFlag:
	     	files.append(projectDir+'/stats/stats.txt')

        combineResults(projectDir+'/result.txt',files)


if __name__ == "__main__":
    main(sys.argv[1:])