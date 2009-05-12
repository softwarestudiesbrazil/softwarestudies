#! /usr/bin/python

import sys, os


def main():
    command = 'matlab -nodisplay -nosplash -r "batch; exit;"'
    error = os.system(command)
        
            

if __name__ == "__main__":
    main()
