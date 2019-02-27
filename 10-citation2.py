"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
from datetime import datetime
import math
from math import radians, cos, sin, asin, sqrt
import csv
import numpy as np
import pandas as pd
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

def dump(fName, dictionary, header):
    mapf = open(fName, 'w', encoding='utf-8')
    mapwriter = csv.writer(mapf)
    mapwriter.writerow(header)
    for key in dictionary:
        l = list(key)
        r = list(dictionary[key])
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
df_assignee = pd.read_csv(keysFile2, usecols = ['patent_id','assignee_numid'], dtype={'patent_id':str,'assignee_numid':int})

# initialize hashtable
acc_fwd_cit = {}
acc_back_cit = {}
counter = 0
# loop through citations
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Starting with citations")
searchf = open(searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
for citation in sreader:
    if sreader.line_num == 1:
        continue
    year = int(citation[0])
    patent_id = citation[1]
    citation_id = citation[2]

    df_ip = df_inventor[df_inventor['patent_id']==patent_id]
    df_ic = df_inventor[df_inventor['patent_id']==citation_id]
    df_ap = df_assignee[df_assignee['patent_id']==patent_id]
    df_ac = df_assignee[df_assignee['patent_id']==citation_id]

    fc_dict = {}
    bc_dict = {}
    for iprow in df_ip.itertuples():
        for icrow in df_ic.itertuples():
            for aprow in df_ap.itertuples():
                for acrow in df_ac.itertuples():
                    ip_loc = iprow[3]
                    if ip_loc < 0:
                        ip_loc = iprow[4]
                        if ip_loc < 0:
                            ip_loc = iprow[5]

                    ic_loc = icrow[3]
                    if ic_loc < 0:
                        ic_loc = icrow[4]
                        if ic_loc < 0:
                            ic_loc = icrow[5]
#                    print(patent_id + " ( " + str(aprow[2]) + " ) " +  " : " + iprow[2] + " ( " + str(ip_loc) + " ) -> " + citation_id + " ( " + str(acrow[2]) + " ) " + " : " + icrow[2] + " ( " + str(ic_loc) + " )")
                    ap = aprow[2]
                    ac = acrow[2]

                    fc_dict = assign_flow(fc_dict, year, ip_loc, ic_loc, ap, ac)
                    bc_dict = assign_flow(bc_dict, year, ic_loc, ip_loc, ac, ap)

    acc_fwd_cit = update(acc_fwd_cit, fc_dict, [0,0,0,0,0])
    acc_back_cit = update(acc_back_cit, bc_dict, [0,0,0,0,0])

    if sreader.line_num%50 == 0:
        print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " " + str(sreader.line_num) + " lines read")
        dump(fc_outputFileName, acc_fwd_cit, fc_outputheader)
        dump(bc_outputFileName, acc_back_cit, bc_outputheader)

# dump final output
dump(fc_outputFileName, acc_fwd_cit, fc_outputheader)
dump(bc_outputFileName, acc_back_cit, bc_outputheader)
