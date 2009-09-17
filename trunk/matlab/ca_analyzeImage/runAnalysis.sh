#!/bin/bash

# example: ./runAnalysis.sh media.onemanga.com/

if [ $# -ne 1 ]
then
    echo "Usage: $0 <path to images>"
    echo "e.g. $0 media.onemanga.com/mangas/00000100/00000001/"
    exit
fi

### constants
ASTANA_LOGIN="jeremydouglass@astana.ucsd.edu"

# path to source on Astana
SOURCE_PREFIX="/Volumes/SWS02/projects/jeremy/comics/manga/onemanga-all"
# path to results on Astana
RESULT_PREFIX="/Volumes/SWS02/projects/jeremy/comics/manga/onemanga-all-results"
# path to workspace
WORKSPACE_PREFIX="/u1/jdouglas/workspace"

MATLAB_PATH="/u1/jdouglas/tools/softwarestudies/matlab/ca_analyzeImage"

LOG_FILE="job.log"
INPUT_FILE="input.txt"
OUTPUT_FILE="output.txt"

### make sure the argument has a trailing slash
TARGET=`echo "$1" | sed -e "s/\/*$//" `/

### create directory structure 
mkdir -p $WORKSPACE_PREFIX/$TARGET

### create log file
echo "[`date`] Start processing $TARGET" > $WORKSPACE_PREFIX/$TARGET$LOG_FILE

### rsync from source
rsync -avz --exclude=".DS_Store" $ASTANA_LOGIN:$SOURCE_PREFIX/$TARGET $WORKSPACE_PREFIX/$TARGET

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: rsync from source" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi

### create a list of all images
find $WORKSPACE_PREFIX/$TARGET -iname "*.jpg" > $WORKSPACE_PREFIX/$TARGET$INPUT_FILE

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: creating list of images" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi

### run matlab
matlab -nodisplay -nojvm -r "path(path,'$MATLAB_PATH'); analyzeImage('$WORKSPACE_PREFIX/$TARGET$INPUT_FILE','$WORKSPACE_PREFIX/$TARGET$OUTPUT_FILE','$WORKSPACE_PREFIX/$TARGET$LOG_FILE'); exit;"

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: matlab" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi

### remove *.jpg
find $WORKSPACE_PREFIX/$TARGET -iname "*.jpg" -exec rm '{}' \;

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: deleting *.jpg" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi

### remove empty directories
find $WORKSPACE_PREFIX/$TARGET -empty -exec rmdir '{}' \;

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: deleting empty directories" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi

### make sure the directory structure at home is correct
ssh $ASTANA_LOGIN "mkdir -p $RESULT_PREFIX/$TARGET"

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: preparing result directory structure" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi


### rsync results back
echo "[`date`] Rsyncing results back" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE
rsync -avz $WORKSPACE_PREFIX/$TARGET $ASTANA_LOGIN:$RESULT_PREFIX/$TARGET

if [ $? -ne 0 ]
then
    echo "[`date`] ERROR: rsync results back" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE  
fi


### done!
echo "[`date`] Done!" >> $WORKSPACE_PREFIX/$TARGET$LOG_FILE
