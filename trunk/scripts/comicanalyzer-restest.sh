#!/bin/bash

rm /Users/devon/Desktop/restest0.1.txt
rm /Users/devon/Desktop/restest0.2.txt
rm /Users/devon/Desktop/restest0.5.txt
rm /Users/devon/Desktop/restest1.0.txt
rm /Users/devon/Desktop/restest2.0.txt
rm /Users/devon/Desktop/restest0.txt
rm /Users/devon/Desktop/restest-30.txt
rm /Users/devon/Desktop/restestfoo.txt

comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest0.1.txt -r 0.1 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest0.2.txt -r 0.2 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest0.5.txt -r 0.5 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest1.0.txt -r 1.0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest2.0.txt -r 2.0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest0.txt -r 0 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restest-30.txt -r -30 --hres 3 &
comicanalyzer.py -i /Users/devon/Desktop/manga-testset/ -o /Users/devon/Desktop/restestfoo.txt -r foo --hres 3 &
