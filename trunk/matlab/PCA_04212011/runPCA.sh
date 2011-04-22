#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Usage: `basename $0` {path-to-txt} {prefix}"
    exit
fi

SCRIPTPATH=$0;
SCRIPTPATH=${SCRIPTPATH%/*}
matlab -nodisplay -r "path(path,'$SCRIPTPATH');runPCA('$1','$2');exit;"
