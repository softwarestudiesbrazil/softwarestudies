#!/usr/bin/env python
'''
Created on Oct 9, 2009

@author: Sunsern
'''

import sys,getopt,string

######## 
HOSTNAME = "localhost"
USER = ""
PASSWD = ""
DB = "softwarestudies"
########

def usage():
    return 'importToMysql v1.1' \
           'USAGE: importToMysql.py [-i] <results.txt> <set-name> <set-description>'

def die(msg):
    print msg
    sys.exit(2)


def addSet(setName,setDescription):
    # cast to lower case
    setName = setName.lower()
    retval = 'INSERT INTO sets(name,description) ' \
             'VALUES (\"%s\",\"%s\");\n'%(setName,setDescription)
    return retval

def addFeatureType(featureName):
    # cast to lower case
    featureName = featureName.lower()
    retval = 'INSERT INTO featuretypes(name) ' \
             'VALUES (\"%s\");\n'%(featureName)
    return retval


def addObject(objectName,url,setId):
    # cast to lower case
    objectName = objectName.lower()
    # try to insert the new set
    retval = 'INSERT INTO objects(set_id,name,URL) ' \
             'VALUES (%s,\"%s\",\"%s\");\n'%(setId,objectName,url)
    return retval


def addFeatureValue(objectId,featureTypeId,value):
    if (type(value) is float) and value == value:
        #print 'float case'
        retval = 'INSERT INTO features(objects_id,featuretypes_id,value_float,value_str) ' \
                 'VALUES (%s,%s,%s,NULL);\n'%(objectId,featureTypeId,value)
    else:
        #print 'string case'
        retval = 'INSERT INTO features(objects_id,featuretypes_id,value_float,value_str) ' \
                 'VALUES (%s,%s,NULL,\"%s\");\n'%(objectId,featureTypeId,str(value))
    return retval

def mysql_import(sql):
    import MySQLdb
    conn = MySQLdb.connect (host = HOSTNAME,
                            user = USER,
                            passwd = PASSWD,
                            db = DB)
    cursor = conn.cursor()

    total = len(sql)
    counter = 1
    for line in sql:
        print 'importing to mysql server[%d/%d]'%(counter,total)
        counter = counter + 1
        try:
            cursor.execute(line)
        except:
            pass

    conn.commit()
    conn.close()


def main():

    importFlag = False
    outputFile = None
    inputFile = None

    try:
        opts,args = getopt.getopt(sys.argv[1:], 'o:ih', 
                                   ['help','import'])
    except getopt.GetoptError:
        die('Error: Illegal arguments\n ' + usage())
        
    for o,a in opts:
        if o in ('-h','--help'):
            die(usage())
        elif o in ('-i','--import'):
            importFlag = True
        elif o in ('-o'):
            outputFile = a
        else:
            assert False, "unhandled option"

    if len(args) != 3:
        die('error #args')
    else:
        inputFile      = args[0]
        setName        = args[1]
        setDescription = args[2]
    
        
    # convert CVS to SQL commands
    sql = convertToSql(inputFile,setName,setDescription)
        
    if outputFile == None:
        outputFile = inputFile + '.sql'

    # write SQL commands to a file        
    fout = open(outputFile,'w')
    fout.write(string.join(sql,''))
    fout.close()

    # import into mysql if needed
    if importFlag:
        mysql_import(sql)


def convertToSql(inputFile,setName,setDescription):
    # sql is a list of strings. each entry is a sql command
    sql = []
    
    sql.append(addSet(setName,setDescription))
    sql.append('SET @SETID = LAST_INSERT_ID();\n')
    
    infile = open(inputFile,'r')
        
    # read header
    l = infile.readline()
    l = l.rstrip('\n')
    headers = l.split(',')
    headers = headers[1:]
    fid = []
    i = 1
    for elem in headers:
        sql.append(addFeatureType(elem))
        featureTypeID = '@FEATUREID%d'%i
        sql.append('SET %s = LAST_INSERT_ID();\n'%featureTypeID)
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
        sql.append(addObject(obj, '','@SETID'))
        sql.append('SET @OBJECTID = LAST_INSERT_ID();\n')
        fvec = fvec[1:]
        for i in range(len(fvec)):
            feature = fvec[i]
            # try to cast to float
            try:
                fv = float(feature)
            except ValueError:
                fv = feature
            sql.append(addFeatureValue('@OBJECTID', fid[i], fv))
        
    infile.close()
    return sql

if __name__ == '__main__':
    main()
