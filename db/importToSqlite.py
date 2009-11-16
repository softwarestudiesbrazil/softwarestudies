#!/usr/bin/env python
'''
Created on Oct 9, 2009

@author: Sunsern
'''

import sys,getopt,string,sqlite3,datetime


def usage():
    return 'importToSqlite v1.0\n' \
           'USAGE: importToSqlite.py <dbname> <resultfile> <set-name> <set-description>'

def die(msg):
    print msg
    sys.exit(2)


def addSet(c,setName,setDescription):
    # cast setName to lower case
    setName = setName.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO object_set(name,description,update_date) ' \
              'VALUES (?,?,?);',(setName,setDescription,now))
    return c.lastrowid


def addFeatureType(c,featureName):
    # cast featureName to lower case
    featureName = featureName.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO statistic(name,update_date) ' \
              'VALUES (?,?);',(featureName,now))
    return c.lastrowid


def addObject(c,objectName,url,setId):
    # cast to lower case
    objectName = objectName.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO object_(set_id,name,path,update_date) ' \
              'VALUES (?,?,?,?);',(setId,objectName,url,now))
    return c.lastrowid


def addFeatureValue(c,objectId,featureTypeId,value):
    now = datetime.datetime.now()
    if (type(value) is float) and value == value:
        #print 'float case'
        c.execute('INSERT INTO stat_real(obj_id,stat_id,val,update_date) ' \
                  'VALUES (?,?,?,?);',(objectId,featureTypeId,value,now))
    else:
        #print 'string case'
        c.execute('INSERT INTO stat_text(obj_id,stat_id,val,update_date) ' \
                  'VALUES (?,?,?,?);',(objectId,featureTypeId,value,now))
    return c.lastrowid


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

    setID = addSet(c,setName,setDescription)

    infile = open(inputFile,'r')
        
    # read header
    l = infile.readline()
    l = l.rstrip('\n')
    headers = l.split(',')
    headers = headers[1:]
    fid = []
    i = 1
    for elem in headers:
        featureTypeID = addFeatureType(c,elem)
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
        objectID = addObject(c,obj,'',setID)
        fvec = fvec[1:]
        for i in range(len(fvec)):
            feature = fvec[i]
            # try to cast to float
            try:
                fv = float(feature)
            except ValueError:
                fv = feature
            addFeatureValue(c, objectID, fid[i], fv)
        
    infile.close()
    conn.commit()
    conn.close()

if __name__ == '__main__':
    main()
