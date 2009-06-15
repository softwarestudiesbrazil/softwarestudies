#!/usr/bin/env python

import getopt, sys
import ca_prep, ca_analyze

# ca_project - process a project
# author: Sunsern Cheamanunkul
# data: 6/15/2009


def usage():
    print 'USAGE: %s [OPTIONS] <project directory>'%('ca_project')
    print 'OPTIONS' 
    print '\t-h,--help          \tShow this usage screen.' 
    print '\t--prep_arg ARGS    \tca_prep arguments'
    print '\t--analyze_arg ARGS \tca_analyze arguments.'


def main(arguments):

    prep_arg = None
    analyze_arg = None

    try:
        opts,args = getopt.getopt(arguments, 'h', 
                                  ['prep_arg=','analyze_arg=','help'])
    except getopt.GetoptError:
        print 'Error: Illegal arguments'
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ('-h','--help'):
            usage()
            sys.exit()
        elif o in ('--prep_arg'):
            prep_arg = a
        elif o in ('--analyze_arg'):
           analyze_arg = a
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

    # run ca_prep
    if prep_arg != None:
        prep_arg = prep_arg + ' ' + projectDir
        ca_prep.main(prep_arg.split(' '))
    else:
        ca_prep.main([projectDir])


    # run ca_analyze
    if analyze_arg != None:
        analyze_arg = analyze_arg + ' ' + projectDir
        ca_analyze.main(analyze_arg.split(' '))
    else:
        ca_analyze.main([projectDir])



if __name__ == "__main__":
    main(sys.argv[1:])
