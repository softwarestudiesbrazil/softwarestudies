#!/usr/bin/env python
'''
Updated on Mar 25, 2010

@author: Sunsern
'''

import sys,getopt,string,sqlite3,datetime


def usage():
    return 'importToSqlite v2.0\n' \
           'USAGE: importToSqlite.py <dbname> <resultfile> <set-name> <set-description>'

def die(msg):
    print msg
    sys.exit(2)


def addSet(c,name,desc):
    name = name.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO object_set(name,description,'\
              'update_date) ' \
              'VALUES (?,?,?);',(name,desc,now))
    #print 'add set(%s,%s)'%(name,desc)
    return c.lastrowid


def addFeatureType(c,name,ftype):
    name = name.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO statistic(name,update_date,'\
              'type) ' \
              'VALUES (?,?,?);',(name,now,ftype))
    #print 'add ftype(%s,%s)'%(name,ftype)
    return c.lastrowid


def addObject(c,name,url,setid):
    name = name.lower()
    now = datetime.datetime.now()
    c.execute('INSERT INTO object_(set_id,name,path,'\
              'obj_date,update_date) ' \
              'VALUES (?,?,?,?,?);',(setid,name,url,
                                     now,now))
    #print 'add object'
    return c.lastrowid


def addFeatureValue(c,objectid,ftid,ftype,value):
    now = datetime.datetime.now()
    if (ftype == 'int'):
        #print 'int case'
        c.execute('INSERT INTO stat_int(obj_id,stat_id,'\
                  'val,update_date) ' \
                  'VALUES (?,?,?,?);',(objectid,ftid,
                                       value,now))
    elif (ftype == 'float'):
        #print 'float case'
        c.execute('INSERT INTO stat_real(obj_id,stat_id,'\
                  'val,update_date) ' \
                  'VALUES (?,?,?,?);',(objectid,ftid,
                                       value,now))
    else:
        #print 'string case'
        c.execute('INSERT INTO stat_text(obj_id,stat_id,'
                  'val,update_date) ' \
                  'VALUES (?,?,?,?);',(objectid,ftid,
                                       value,now))
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
    
    features = []
    ftypes = []
    fid = []

    # read header
    l = infile.readline()
    l = l.rstrip('\n')
    headers = l.split(',')
    for elem in headers:
        features.append(elem)
    
    # read datatype line
    l = infile.readline()
    l = l.rstrip('\n')
    headers = l.split(',')
    for elem in headers:
        ftypes.append(elem)

    # add features
    for i in range(len(features)):
        fid.append(addFeatureType(c,features[i],ftypes[i]))

    # start reading data    
    for line in infile:
        line = line.rstrip('\n')
        fvec = line.split(',')
        url = fvec[0]
        print 'processing %s'%url
        objectID = addObject(c,'',url,setID)
        fvec = fvec[1:]
        for i in range(len(fvec)):
            fv = fvec[i]
            addFeatureValue(c, objectID, fid[i+1], ftypes[i+1], fv)
        
    infile.close()
    conn.commit()
    conn.close()

if __name__ == '__main__':
    main()
