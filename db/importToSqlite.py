#!/usr/bin/env python
'''
Created on Oct 9, 2009

@author: Sunsern
'''

import sys,getopt,string,sqlite3


def usage():
    return 'importToSqlite v1.0' \
           'USAGE: importToSqlite.py <dbname> <results.txt> <set-name> <set-description>'

def die(msg):
    print msg
    sys.exit(2)


def addSet(setName,setDescription):
    # cast to lower case
    setName = setName.lower()
    retval = 'INSERT INTO object_set(name,description) ' \
             'VALUES (\"%s\",\"%s\");'%(setName,setDescription)
    return retval

def addFeatureType(featureName):
    # cast to lower case
    featureName = featureName.lower()
    retval = 'INSERT INTO statistic(name) ' \
             'VALUES (\"%s\");'%(featureName)
    return retval


def addObject(objectName,url,setId):
    # cast to lower case
    objectName = objectName.lower()
    retval = 'INSERT INTO object_(set_id,name,path) ' \
             'VALUES (%s,\"%s\",\"%s\");'%(setId,objectName,url)
    return retval


def addFeatureValue(objectId,featureTypeId,value):
    if (type(value) is float) and value == value:
        #print 'float case'
        retval = 'INSERT INTO stat_real(obj_id,stat_id,val) ' \
                 'VALUES (%s,%s,%s);'%(objectId,featureTypeId,value)
    else:
        #print 'string case'
        retval = 'INSERT INTO stat_text(obj_id,stat_id,val) ' \
                 'VALUES (%s,%s,\"%s\");'%(objectId,featureTypeId,str(value))
    return retval


def main():

    inputFile = None
    dbname = None

    try:
        opts,args = getopt.getopt(sys.argv[1:], 'h', 
                                   ['help'])
    except getopt.GetoptError:
        die('Error: Illegal arguments\n ' + usage())
        
    for o,a in opts:
        if o in ('-h','--help'):
            die(usage())
        else:
            assert False, "unhandled option"

    if len(args) != 4:
        die('error #args')
    else:
        dbname         = args[0]
        inputFile      = args[1]
        setName        = args[2]
        setDescription = args[3]
    
    # import
    sqlite_import(inputFile,dbname,setName,setDescription)
        

def sqlite_import(inputFile,dbname,setName,setDescription):

    conn = sqlite3.connect(dbname)
    c = conn.cursor()

    c.execute(addSet(setName,setDescription))
    setID = str(c.lastrowid)

    infile = open(inputFile,'r')
        
    # read header
    l = infile.readline()
    l = l.rstrip('\n')
    headers = l.split(',')
    headers = headers[1:]
    fid = []
    i = 1
    for elem in headers:
        c.execute(addFeatureType(elem))
        featureTypeID = str(c.lastrowid)
        fid.append(featureTypeID)
        i = i + 1
    
    # skip datatype line
    infile.readline()
    
    # start reading data    
    for line in infile:
        line = line.rstrip('\n')
        fvec = line.split(',')
        obj = fvec[0]
        print 'processing %s'%obj
        c.execute(addObject(obj,'',setID))
        objectID = str(c.lastrowid)
        fvec = fvec[1:]
        for i in range(len(fvec)):
            feature = fvec[i]
            # try to cast to float
            try:
                fv = float(feature)
            except ValueError:
                fv = feature
            c.execute(addFeatureValue(objectID, fid[i], fv))
        
    infile.close()
    conn.commit()
    conn.close()

if __name__ == '__main__':
    main()
