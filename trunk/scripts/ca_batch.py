#! /usr/bin/env python

import sys,os,getopt,shutil,string
import ca_project

def usage():
     print 'USAGE: ca_batch.py <cabatch.cfg>'


def process(cfgFile):

     # check for cfgFile
     if not os.path.exists(cfgFile):
          print 'Error: ' + cfgFile + ' does not exist!'
          sys.exit(1)

     f = open(cfgFile,'rU')

     # check file format
     for s in f:
          s = s.strip('\n')
          l = s.split('\t')
          if len(l) != 2:
               print 'Error: wrong format in ' + cfgFile + '.'
               print 'Please make sure you use tab to separate the columns and'
               print 'there are only 2 columns per line.'
               sys.exit(1)

     f.close()

     f = open(cfgFile,'rU')

     print '== Starting ca_batch =='

     for s in f:
          s = s.strip('\n')
          l = s.split('\t')
          l0 = l[0].strip(' ')
          l1 = l[1].strip(' ')
          print '>> Processing ' + l1
          if (l0.lower().startswith(('http','ftp'))):
               ca_project.main(['--prep_arg','--url ' + l0 + ' --redump',\
                                '--analyze_arg','--mode video',l1])
          else:
               ca_project.main([l1])

          #shutil.rmtree(os.path.join(l[1],'images'))
     f.close()




def main():

     try:
          opts,args = getopt.getopt(sys.argv[1:], 'h',
                                    ['help'])
     except getopt.GetoptError:
          print 'Error: Illegal arguments'
          usage()
          sys.exit(2)
          
     for o, a in opts:
          if o in ('-h','--help'):
               usage()
               sys.exit()
          else:
               assert False, "unhandled option"
     
     if len(args) < 1:
          print 'need cfg file'
          sys.exit(1);
     
     process(args[0])


if __name__ == "__main__":
    main()
