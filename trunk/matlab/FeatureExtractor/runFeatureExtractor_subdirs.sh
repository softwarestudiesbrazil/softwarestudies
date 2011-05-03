#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Usage: `basename $0` {image path} {prefix}"
    exit
fi

SCRIPTPATH=$0;
SCRIPTPATH=${SCRIPTPATH%/*}
matlab -nodisplay -r "path(path,'$SCRIPTPATH');FeatureExtractor('$1','$2','-r');exit;"
