"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import sys
from datetime import datetime
import math
from math import radians, cos, sin, asin, sqrt
import csv
import numpy as np
import pandas as pd
import time
from time import gmtime, strftime

pathPrefix = "/Users/aiyenggar/processed/patents/"

# year,patent_id,inventor_id,ua1,ua2,ua3,inventorseq,country,latlongid,latitude,longitude
keysFile1=pathPrefix+"20190227-inventor.csv"

# year,patent_id,assignee_numid,ua1,ua2,ua3,assigneetype,assigneeseq,assignee,country,latlongid,latitude,longitude
keysFile2=pathPrefix+"20190227-assignee.csv"

# application_year,patent_id,citation_id,citation_type,sequence,kind,application_date
searchFileName=pathPrefix+"20190227-citation-2001-2018.csv"

# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Outside Firm: q3
# Outside Cluster, Within Firm: q4
# Not determinable: q5


fc_outputheader=["ua", "year", "fq1", "fq2", "fq3", "fq4", "fq5"]
bc_outputheader=["ua", "year", "bq1", "bq2", "bq3", "bq4", "bq5"]
fc_outputFileName=pathPrefix+"forward_citations.csv"
bc_outputFileName=pathPrefix+"backward_citations.csv"

errorFileName=pathPrefix+"error_patents.csv"

def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    try:
        # convert decimal degrees to radians
        lon1, lat1, lon2, lat2 = map(radians, [float(lon1), float(lat1), float(lon2), float(lat2)])
    except ValueError:
        return 63670
    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    km = 6367 * c
    return km

def dump(fName, dictionary, header, tolist):
    mapf = open(fName, 'w', encoding='utf-8')
    mapwriter = csv.writer(mapf)
    mapwriter.writerow(header)
    for key in dictionary:
        if tolist:
            l = list(key)
            r = list(dictionary[key])
        else:
            l = [str(key)]
            r = [str(dictionary[key])]
        mapwriter.writerow(l+r)
    mapf.close()
    return

def assign_flow(dictionary, fo_year, focal_location, other_location, focal_assignee, other_assignee):
    if focal_location >= 0:
        key = tuple([focal_location, fo_year])
        prior = [0, 0, 0, 0, 0]
        if key in dictionary:
            prior = dictionary[key]
        if (focal_assignee < 0 or other_location < 0 or other_assignee < 0):
            prior[4] += 1
        else:
            # Guaranteed that each of focal_location, other_location, focal_assignee, other_assignee are valid
            if focal_location == other_location:
                if focal_assignee == other_assignee:
                    prior[0] += 1
                else:
                    prior[1] += 1
            else:
                if focal_assignee == other_assignee:
                    prior[3] += 1
                else:
                    prior[2] += 1
        dictionary[key] = prior
    return dictionary

def update(master_dictionary, updates_dict, default):
    for keys in updates_dict:
        change = updates_dict[keys]
        master = default
        if keys in master_dictionary:
            master = master_dictionary[keys]
        for index in range(0,5):
            master[index] += change[index]
        master_dictionary[keys] = master
    return master_dictionary

# read keysFile1
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Reading " + keysFile1)
df_inventor = pd.read_csv(keysFile1, usecols = ['patent_id','inventor_id','ua1','ua2','ua3','latitude','longitude'], dtype={'patent_id':str,'inventor_id':str,'ua1':int,'ua2':int,'ua3':int,'latitude':float,'longitude':float})

# read keysFile2
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Reading " + keysFile2)
df_assignee = pd.read_csv(keysFile2, usecols = ['patent_id','assignee_numid', 'assigneeseq'], dtype={'patent_id':str,'assignee_numid':int, 'assigneeseq':int})

# initialize hashtable
conditions10 = [ df_inventor['ua1'] >= 0, df_inventor['ua2'] >= 0, df_inventor['ua3'] >= 0 ]
choices10 = [ df_inventor['ua1'], df_inventor['ua2'], df_inventor['ua3'] ]
df_inventor['ua'] = np.select(conditions10, choices10, default=-1)
df_inventor['ualist'] = df_inventor['ua'].apply(lambda x: [x])
df_inventor = df_inventor[['patent_id', 'ualist']]
df_inventor = df_inventor.groupby('patent_id').agg({'ualist':'sum'})

acc_fwd_cit = {}
acc_back_cit = {}
counter = 0
error_lines = 0
missing_dict = {}
# loop through citations
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Starting with citations")
searchf = open(searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
t1 = 0
t2 = 0
t3 = 0
for citation in sreader:
    if sreader.line_num == 1:
        continue
    year = int(citation[0])
    patent_id = citation[1]
    citation_id = citation[2]

    try:
        """ Timing """
        start = time.time()
        p_loc = pd.Series(df_inventor.loc[patent_id]['ua'])
        end = time.time()
        t1 += end - start

        """ Timing """
        start = time.time()
        c_loc = pd.Series(df_inventor.loc[citation_id]['ua'])
        end = time.time()
        t2 += end - start

        """ Timing """
        start = time.time()
        p_ass = pd.Series(df_assignee.loc[patent_id]['assignee_numid'])
        c_ass = pd.Series(df_assignee.loc[citation_id]['assignee_numid'])
        end = time.time()
        t3 += end - start
    except:
        error_lines += 1
        missingkey = str(sys.exc_info()[1]).split('[')[1].split(']')[0]
        if missingkey not in missing_dict:
            missing_dict[missingkey] = 1
        else:
            missing_dict[missingkey] += 1
        continue
    fc_dict = {}
    bc_dict = {}

    for i1, iprow in p_loc.iteritems():
        for i2, icrow in c_loc.iteritems():
            for i3, aprow in p_ass.iteritems():
                for i4, acrow in c_ass.iteritems():
#                    print(patent_id + " ( " + str(aprow) + " ) " +  " : " + " ( " + str(iprow) + " ) -> " + citation_id + " ( " + str(acrow) + " ) " + " : " + " ( " + str(icrow) + " )")
                    fc_dict = assign_flow(fc_dict, year, iprow, icrow, aprow, acrow)
                    bc_dict = assign_flow(bc_dict, year, icrow, iprow, acrow, aprow)

    acc_fwd_cit = update(acc_fwd_cit, fc_dict, [0,0,0,0,0])
    acc_back_cit = update(acc_back_cit, bc_dict, [0,0,0,0,0])

    if sreader.line_num%50 == 0:
        print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " lines read = " + str(sreader.line_num) + " error lines = " + str(error_lines) + " t1 = " + str(round(t1,2)) + ", t2 = " + str(round(t2,2)) + ", t3 = " + str(round(t3,2)))
        dump(fc_outputFileName, acc_fwd_cit, fc_outputheader, True)
        dump(bc_outputFileName, acc_back_cit, bc_outputheader, True)
        dump(errorFileName, missing_dict, ["patent_id", "num_lines"], False)
        counter += 1
        if counter > 1:
            break


# dump final output
dump(fc_outputFileName, acc_fwd_cit, fc_outputheader, True)
dump(bc_outputFileName, acc_back_cit, bc_outputheader, True)
dump(errorFileName, missing_dict, ["patent_id", "num_lines"], False)
