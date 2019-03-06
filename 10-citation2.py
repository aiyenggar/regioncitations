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

#backwardCitationsConfig="Expanded"
backwardCitationsConfig="Pure-Collapsed"
fileDatePrefix="20190306"
urbanareaConfig="ua1"
calculateCitationDistance=True
outputPrefix = fileDatePrefix + "-" + urbanareaConfig + "-" + "CalcDist-" + str(calculateCitationDistance)
pathPrefix = "/Users/aiyenggar/processed/patents/"

# the below file needs to be augmented to include a list of latlongid, so whenever uaid is -1, one may fall back onto the latlongid to then calculate the actual distance
# patent_id,assigneelist,ualist
keysFile1=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-" + "-patent_list_location_assignee.csv"
# application_year,patent_id,citation_id,citation_type,sequence,kind,application_date
searchFileName=pathPrefix + fileDatePrefix + "-citation.csv"

# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Outside Firm: q3
# Outside Cluster, Within Firm: q4
# Not determinable: q5

fc_outputheader=["uaid", "year", "citation_type", "fq1", "fq2", "fq3", "fq4", "fq5"]
bc_outputheader=["uaid", "year", "citation_type", "bq1", "bq2", "bq3", "bq4", "bq5"]
fc_outputFileName=pathPrefix + outputPrefix + "-forward_citations.csv"
bc_outputFileName=pathPrefix + outputPrefix + "-backward_citations.csv"

invErrorFileName=pathPrefix + outputPrefix + "-errinv.csv"
assErrorFileName=pathPrefix + outputPrefix + "-errass.csv"

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
            l = [key]
            r = [str(dictionary[key])]
        mapwriter.writerow(l+r)
    mapf.close()
    return

def assign_flow(dictionary, fo_year, citationtype, focal_location, other_location, focal_assignee, other_assignee):
    if focal_location >= 0:
        key = tuple([focal_location, fo_year, citationtype])
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

def assign_flow2(dictionary, fo_year, citationtype, focal_location, focal_assignee, other_assignee): #flow within assignee is marked on quadrant 1, and flow outside assignee is marked on quadrant 2
    if focal_location >= 0:
        key = tuple([focal_location, fo_year, citationtype])
        prior = [0, 0, 0, 0, 0]
        if key in dictionary:
            prior = dictionary[key]
        if (focal_assignee < 0 or other_assignee < 0):
            prior[4] = 1 # quadrant 5
        else:
            if focal_assignee == other_assignee:
                prior[0] = 1 # quadrant 1
            else:
                prior[1] = 1 # quadrant 2
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

def adderr(dic, key):
    if key not in dic:
        dic[key] = 1
    else:
        dic[key] += 1
    return dic

# read keysFile1
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Start Reading " + keysFile1)
inventor_dict = pd.read_csv(keysFile1, usecols = ['patent_id','ualist'], dtype={'patent_id':str,'ualist':str}, index_col='patent_id').to_dict()
assignee_dict = pd.read_csv(keysFile1, usecols = ['patent_id','assigneelist'], dtype={'patent_id':str,'assigneelist':str}, index_col='patent_id').to_dict()
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Done Reading " + keysFile1)

# initialize hashtable
acc_fwd_cit = {}
acc_back_cit = {}
counter = 0
inventor_error_lines = 0
assignee_error_lines = 0
inventor_missing_dict = {}
assignee_missing_dict = {}

# loop through citations
print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Processing Citations")
searchf = open(searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
t1 = 0
t2 = 0
t3 = 0
status_line = 0
for citation in sreader:
    """ Timing """
    start = time.time()
    if sreader.line_num == 1:
        continue
    year = int(citation[0])
    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    type_citation = int(citation[3]) # 1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party
    seq_citation = int(citation[4])
    kind_citation = citation[5] # B1, A etc

    try:
        tmplist = inventor_dict['ualist'][patent_id]
        if tmplist != tmplist:
            inventor_error_lines += 1
            inventor_missing_dict = adderr(inventor_missing_dict, patent_id)
            p_loc = ['-3']
        else:
            p_loc = tmplist.split(',')
    except KeyError:
        inventor_error_lines += 1
        inventor_missing_dict = adderr(inventor_missing_dict, str(sys.exc_info()[1]).split('\'')[1])
        continue # Cannot go on
    except:
        print(str(sys.exc_info()[0]) + " PATENT -> " + str(sys.exc_info()[1]))
        inventor_error_lines += 1
        continue # Cannot go on

    try:
        tmplist = inventor_dict['ualist'][citation_id]
        if tmplist != tmplist:
            inventor_error_lines += 1
            inventor_missing_dict = adderr(inventor_missing_dict, citation_id)
            c_loc = ['-3']
        else:
            c_loc = tmplist.split(',')
    except KeyError:
        inventor_error_lines += 1
        inventor_missing_dict = adderr(inventor_missing_dict, str(sys.exc_info()[1]).split('\'')[1])
        continue # Cannot go on
    except:
        print(str(sys.exc_info()[0]) + " CITATION -> " + citation_id + " >> " + str(sys.exc_info()[1]))
        inventor_error_lines += 1
        continue # Cannot go on

    try:
        tmplist = assignee_dict['assigneelist'][patent_id]
        if tmplist != tmplist:
            assignee_error_lines += 1
            assignee_missing_dict = adderr(assignee_missing_dict, patent_id)
            p_ass = ['-3']
        else:
            p_ass = tmplist.split(',')
    except:
        print(str(sys.exc_info()[0]) + " PASS -> " + str(sys.exc_info()[1]))
        assignee_error_lines += 1
        assignee_missing_dict = adderr(assignee_missing_dict, str(sys.exc_info()[1]).split('\'')[1])
        p_ass = ['-4']
        # Go on, do not quit

    try:
        tmplist = assignee_dict['assigneelist'][citation_id]
        if tmplist != tmplist:
            assignee_error_lines += 1
            assignee_missing_dict = adderr(assignee_missing_dict, citation_id)
            c_ass = ['-3']
        else:
            c_ass = tmplist.split(',')
    except:
        print(str(sys.exc_info()[0]) + " CASS -> " + citation_id + " >> " + str(sys.exc_info()[1]))
        assignee_error_lines += 1
        assignee_missing_dict = adderr(assignee_missing_dict, str(sys.exc_info()[1]).split('\'')[1])
        c_ass = ['-4']
        # Go on, do not quit

    fc_dict = {}
    bc_dict = {}

    for patloc in p_loc:
        for citloc in c_loc:
            for patass in p_ass:
                for citass in c_ass:
                    """
                    if (int(patass) < -1 or int(citass) < -1 or int(patloc) < -1 or int(citloc) < -1):
                        print(patent_id + " ( " + patass + " ) " +  " : " + " ( " + patloc + " ) -> " + citation_id + " ( " + citass + " ) " + " : " + " ( " + citloc + " )")
                    """
                    fc_dict = assign_flow(fc_dict, year, type_citation, int(patloc), int(citloc), int(patass), int(citass))
                    if (backwardCitationsConfig == "Expanded"): # count expanded citations received
                        bc_dict = assign_flow(bc_dict, year, type_citation, int(citloc), int(patloc), int(citass), int(patass))
                    elif (backwardCitationsConfig == "Pure-Collapsed"): # count pure citations received
                         bc_dict = assign_flow2(bc_dict, year, type_citation, int(citloc), int(citass), int(patass))
                    else:
                        print("Undefined backwardCitationsConfig")
                        exit()

    acc_fwd_cit = update(acc_fwd_cit, fc_dict, [0,0,0,0,0])
    acc_back_cit = update(acc_back_cit, bc_dict, [0,0,0,0,0])

    if sreader.line_num >= status_line + 3500000:
        print(strftime("%Y-%m-%d %H:%M:%S", gmtime()) + " Processed = " + str(sreader.line_num) + " InvErr = " + str(inventor_error_lines) + " AssErr = " + str(assignee_error_lines) + " t1 = " + str(round(t1,2)))
        status_line = sreader.line_num
        dump(fc_outputFileName, acc_fwd_cit, fc_outputheader, True)
        dump(bc_outputFileName, acc_back_cit, bc_outputheader, True)
        dump(invErrorFileName, inventor_missing_dict, ["patent_id", "num_lines"], False)
        dump(assErrorFileName, assignee_missing_dict, ["patent_id", "num_lines"], False)
        counter += 1
        if counter < 0:
            break
    end = time.time()
    t1 += end - start

# dump final output
dump(fc_outputFileName, acc_fwd_cit, fc_outputheader, True)
dump(bc_outputFileName, acc_back_cit, bc_outputheader, True)
dump(invErrorFileName, inventor_missing_dict, ["patent_id", "num_lines"], False)
dump(assErrorFileName, assignee_missing_dict, ["patent_id", "num_lines"], False)
# 2019-02-28 21:42:18 Total = 91000027 InvErr = 16235262 AssErr = 17894175 t1 = 7272.67
