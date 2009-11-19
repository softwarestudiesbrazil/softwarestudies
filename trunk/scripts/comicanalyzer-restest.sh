#!/bin/bash

SAVEPATH = "/Users/devon/Desktop"

rm $SAVEPATH/restest0.1.txt
rm $SAVEPATH/restest0.2.txt
rm $SAVEPATH/restest0.5.txt
rm $SAVEPATH/restest1.0.txt
rm $SAVEPATH/restest2.0.txt
rm $SAVEPATH/restest0.txt
rm $SAVEPATH/restest-30.txt
rm $SAVEPATH/restestfoo.txt

comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restest0.1.txt -r 0.1 --hres 3  &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest0.2.txt -r 0.2 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest0.5.txt -r 0.5 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest1.0.txt -r 1.0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest2.0.txt -r 2.0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest0.txt -r 0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestest-30.txt -r -30 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o $SAVEPATH/restestrestestfoo.txt -r foo --hres 3 &
