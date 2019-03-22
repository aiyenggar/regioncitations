"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import sys
from math import radians, cos, sin, asin, sqrt
import numpy as np
import pandas as pd
import time
import geopy.distance

#backwardCitationsConfig="Expanded"
backwardCitationsConfig="Pure-Collapsed"
fileDatePrefix="20190314"
urbanareaConfig="ua3"
calculateCitationDistance=True
distanceTreshold=30.01
degreeTreshold=0.3 # to set the bounding box based on latitude and longitude
outputPrefix = fileDatePrefix + "-" + urbanareaConfig + "-" + "CalcDist" + str(calculateCitationDistance)
pathPrefix = "/Users/aiyenggar/processed/patents/"
validLargest = sys.maxsize

attributeErrorValue=['-2'] # List value is empty
keyErrorValue=['-3'] # No information
defaultErrorValue=['-4']

# the below file needs to be augmented to include a list of latlongid, so whenever uaid is -1, one may fall back onto the latlongid to then calculate the actual distance
# patent_id,assigneelist,latlonglist,ualist
keysFile1=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-patent_list_location_assignee.csv"
# application_year,patent_id,citation_id,citation_type,sequence,kind,application_date
searchFileName=pathPrefix + fileDatePrefix + "-citation.csv"
distancesFile=pathPrefix + "latlong_urbanarea_2.csv"
latlongFile=pathPrefix + "latlong_urbanarea.csv"
# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Outside Firm: q3
# Outside Cluster, Within Firm: q4
# Not determinable: q5

targetdict={}
targetdict[tuple([2003,3459])]=pathPrefix+"2003-3459.csv"
targetdict[tuple([2009,5174])]=pathPrefix+"2009-5174.csv"
targetdict[tuple([1999,666])]=pathPrefix+"1999-666.csv"
targetdict[tuple([2004,5434])]=pathPrefix+"2004-5434.csv"
targetdict[tuple([2006,4359])]=pathPrefix+"2006-4359.csv"
targetdict[tuple([2010,1268])]=pathPrefix+"2010-1268.csv"
targetdict[tuple([2010,3839])]=pathPrefix+"2010-3839.csv"
targetdict[tuple([2006,2898])]=pathPrefix+"2006-2898.csv"

def adderr(dic, key, desc):
    conskey = tuple([key, desc])
    if conskey not in dic:
        dic[conskey] = 1
    else:
        dic[conskey] += 1
    return dic

# read keysFile1
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading Inventor Urban Areas")
inv_uaid_dict = pd.read_csv(keysFile1, usecols = ['patent_id','ualist'], dtype={'patent_id':str,'ualist':str}, index_col='patent_id').to_dict()
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading Assignee")
assignee_dict = pd.read_csv(keysFile1, usecols = ['patent_id','assigneelist'], dtype={'patent_id':str,'assigneelist':str}, index_col='patent_id').to_dict()
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading Inventor Latlong")
inv_latlongid_dict = pd.read_csv(keysFile1, usecols = ['patent_id','latlonglist'], dtype={'patent_id':str,'latlonglist':str}, index_col='patent_id').to_dict()
if calculateCitationDistance:
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading Pre-calculated Distances")
#    distances_dict = pd.read_csv(distancesFile, usecols = ['l_latlongid','r_latlongid','distance'], dtype={'l_latlongid':int,'r_latlongid':int,'distance':float}, index_col=['l_latlongid', 'r_latlongid']).to_dict()
    dist_df = pd.read_csv(distancesFile, usecols = ['l_latlongid','r_latlongid','distance'], dtype={'l_latlongid':int,'r_latlongid':int,'distance':float})
    dist_df.sort_values(by=['l_latlongid','r_latlongid'], inplace=True)
    dist_df['lr']=list(zip(dist_df.l_latlongid, dist_df.r_latlongid))
    dist_df.drop(columns=['l_latlongid','r_latlongid'], inplace=True)
    dist_df.set_index('lr', inplace=True)
    distances_dict = dist_df.to_dict()
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading Latlongid to Latitude, Longitude Mapping")

    latlong_dict = pd.read_csv(latlongFile, usecols = ['latlongid','latitude','longitude'], dtype={'latlongid':int,'latitude':float,'longitude':float}, index_col='latlongid').to_dict()
    # also read the other two files
else:
    distances_dict = None
    latlong_dict = None
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Done Reading ")

# force calculation of all distances
#distances_dict = {}
#distances_dict['distance'] = {}

# initialize hashtable
acc_fwd_cit = {}
acc_back_cit = {}
counter = 0

inventor_missing_dict = {}
assignee_missing_dict = {}

# loop through citations
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processing Citations")
searchf = open(searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
t1 = 0
t2 = 0
t3 = 0
status_line = 0
# raw_citation0 is the value of sreader.line_num at the end
raw_citation1a = 0 # Number of raw citations (not expanded) that have AttributeError on inventor location (nan)
raw_citation1b = 0 # Number of raw citations (not expanded) that have KeyError on inventor location (no entry for that patent-id)
raw_citation1c = 0 # Number of raw citations (not expanded) that have other inventor location problems
raw_citation2a = 0 # Number of raw citations (not expanded) that have AttributeError on assignee
raw_citation2b = 0 # Number of raw citations (not expanded) that have KeyError on assignee
raw_citation2c = 0 # Number of raw citations (not expanded) that have other assignee problems
raw_citation3 = 0 # Number of raw citations that come for processing after parsing of location and assignee
exp_citation1 = 0 # Number of expanded citations seen
exp_citation2 = 0 # Number of expanded citations where patent inventor location and citation inventor location are both defined
exp_citation3 = 0 # Number of expanded citations where patent assignee and citation assignee are both defined
exp_citation4 = 0 # Number of expanded citations where patent inventor location, citation inventor location, patent assignee and citation assignee are all defined
exp_citation5 = 0 # Number of expanded citations that qualify for distance calculation intervention
exp_citation6 = 0 # Number of expanded citations where distance is obtained from the hash table
exp_citation7 = 0 # Number of expanded citations where distance calculation was forced
exp_citation8a = 0 # Number of expanded citations where the bounding box avoided the need for distance calculation, but outside the treshold is determined without knowledge of exact distance
exp_citation8b = 0 # Number of expanded citations where either the latlong of atleast one side is unavailable, and therefore distance is not calculated
exp_citation9a = 0 # Number of expanded citations where calculating distance assigns citation as local (change made to patent location)
exp_citation9b = 0 # Number of expanded citations where calculating distance assigns citation as local (change made to citation location)
exp_citation10a = 0 # Number of expanded citations where calculating distance assigns citation as non-local (change made to patent location)
exp_citation10b = 0 # Number of expanded citations where calculating distance assigns citation as non-local (change made to citation location)
exp_citation11 = 0 # Number of expanded citations where distance was not calculated despite being set to be calculated
exp_citation12 = 0 # Number of expanded citations where calculateCitationDistance is true but where exactly one location is not undefined, so distance calculations cannot be used
exp_citation13 = 0 # Number of expanded citations where patent location is undetermined
exp_citation14 = 0 # Number of expanded citations where citation location is undetermined
exp_citation15 = 0 # Number of expanded citations where either patent location or citation location is undetermined
exp_citation16 = 0 # Number of expanded citations where patent assignee is undetermined
exp_citation17 = 0 # Number of expanded citations where citation assignee is undetermined
exp_citation18 = 0 # Number of expanded citations where either patent assignee or citation assignee is undetermined
exp_citation19 = 0 # Number of expanded citations where patent location or citation location or patent assignee or citation assignee is undetermined

for citation in sreader:
    """ Timing """
    start = time.time()
    if sreader.line_num == 1:
        for erkey in targetdict:
            mapf = open(targetdict[erkey], 'w', encoding='utf-8')
            mapwriter = csv.writer(mapf)
            mapwriter.writerow(citation)
            mapf.close()
        continue
    try:
        year = int(citation[0])
    except ValueError:
        continue

    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    type_citation = int(citation[3]) # 1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party
    seq_citation = int(citation[4])
    kind_citation = citation[5] # B1, A etc
    p_latlongid = defaultErrorValue
    try:
        p_latlongid = inv_latlongid_dict['latlonglist'][patent_id].split(',')
        p_loc = inv_uaid_dict['ualist'][patent_id].split(',')
    except AttributeError:
        raw_citation1a += 1
        inventor_missing_dict = adderr(inventor_missing_dict, patent_id, attributeErrorValue[0]) # str(sys.exc_info()[1]).split('\'')[1]
        p_loc = attributeErrorValue
    except KeyError:
        raw_citation1b += 1
        inventor_missing_dict = adderr(inventor_missing_dict, patent_id, keyErrorValue[0])
        p_loc = keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " PATENT -> " + str(sys.exc_info()[1]))
        raw_citation1c += 1
        p_loc = defaultErrorValue

    c_latlongid = defaultErrorValue
    try:
        c_latlongid = inv_latlongid_dict['latlonglist'][citation_id].split(',')
        c_loc = inv_uaid_dict['ualist'][citation_id].split(',')
    except AttributeError:
        if p_loc != attributeErrorValue:
            raw_citation1a += 1 # Avoid double counting the same line for the same error
        inventor_missing_dict = adderr(inventor_missing_dict, citation_id, attributeErrorValue[0])
        c_loc = attributeErrorValue
    except KeyError:
        if p_loc != keyErrorValue:
            raw_citation1b += 1 # Avoid double counting the same line for the same error
        inventor_missing_dict = adderr(inventor_missing_dict, citation_id, keyErrorValue[0])
        c_loc = keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " CITATION -> " + citation_id + " >> " + str(sys.exc_info()[1]))
        raw_citation1c += 1
        c_loc = defaultErrorValue

    try:
        p_ass = assignee_dict['assigneelist'][patent_id].split(',')
    except AttributeError:
        # we assume the value would have returned nan, implying a missing assignee field
        raw_citation2a += 1
        assignee_missing_dict = adderr(assignee_missing_dict, patent_id, attributeErrorValue[0])
        p_ass = attributeErrorValue
    except KeyError:
        raw_citation2b += 1
        assignee_missing_dict = adderr(assignee_missing_dict, patent_id, keyErrorValue[0])
        p_ass = keyErrorValue
    except:
        raw_citation2c += 1
        print(str(sys.exc_info()[0]) + " PASS -> " + patent_id + " " + str(sys.exc_info()[1]))
        p_ass = defaultErrorValue

    try:
        c_ass = assignee_dict['assigneelist'][citation_id].split(',')
    except AttributeError:
        # we assume the value would have returned nan, implying a missing assignee field
        if p_ass != attributeErrorValue:
            raw_citation2a += 1
        assignee_missing_dict = adderr(assignee_missing_dict, citation_id, attributeErrorValue[0])
        c_ass = attributeErrorValue
    except KeyError:
        if p_ass != keyErrorValue:
            raw_citation2b += 1
        assignee_missing_dict = adderr(assignee_missing_dict, citation_id, keyErrorValue[0])
        c_ass = keyErrorValue
    except:
        if p_ass != defaultErrorValue:
            raw_citation2c += 1
        print(str(sys.exc_info()[0]) + " CASS -> " + citation_id + " >> " + str(sys.exc_info()[1]))
        c_ass = defaultErrorValue

    raw_citation3 += 1

    for pind in range(len(p_loc)):
        for cind in range(len(c_loc)):
            for apind in range(len(p_ass)):
                for acind in range(len(c_ass)):
                    exp_citation1 += 1
                    patloc = int(p_loc[pind])
                    citloc = int(c_loc[cind])
                    patass = int(p_ass[apind])
                    citass = int(c_ass[acind])

                    erkey = tuple([year, citloc])
                    if (erkey not in targetdict) and citloc >= 0:
                        continue

                    f1 = False
                    f2 = False
                    if (patloc >= 0) and (citloc >= 0):
                        exp_citation2 += 1
                        f1 = True

                    if (patass >= 0) and (citass >= 0):
                        exp_citation3 += 1
                        f2 = True

                    if (f1 == True) and (f2 == True):
                        exp_citation4 += 1

                    #print(patent_id + " ( " + str(patass) + " ) " +  " : " + " ( " + str(patloc) + " ) -> " + citation_id + " ( " + str(citass) + " ) " + " : " + " ( " + str(citloc) + " )")

                    if (calculateCitationDistance == True): # this is when intervention is possible
                        if ((patloc >= 0) and (citloc < 0)) or ((patloc < 0) and (citloc >= 0)):
                            if patloc < 0:
                                ch = 0
                            else:
                                ch = 1
                            exp_citation5 += 1
                            patllid = int(p_latlongid[pind])
                            citllid = int(c_latlongid[cind])
                            dist = validLargest
                            if (patllid >= 0) and (citllid >= 0):
                                if tuple([patllid,citllid]) in distances_dict['distance']:
                                    exp_citation6 += 1
                                    dist = distances_dict['distance'][tuple([patllid, citllid])]
                                elif tuple([citllid,patllid]) in distances_dict['distance']:
                                    exp_citation6 += 1
                                    dist = distances_dict['distance'][tuple([citllid, patllid])]
                                else:
                                    # We do not expect surprises since negative llid's are already if'd out
                                    l_lat = latlong_dict['latitude'][patllid]
                                    l_long = latlong_dict['longitude'][patllid]
                                    r_lat = latlong_dict['latitude'][citllid]
                                    r_long = latlong_dict['longitude'][citllid]
                                    if (l_lat < r_lat + degreeTreshold) and (l_lat > r_lat - degreeTreshold) and (l_long < r_long + degreeTreshold) and (l_long > r_long - degreeTreshold):
                                        exp_citation7 += 1
                                        #dist = haversine(l_lat, l_long, r_lat, r_long)
                                        dist = round(geopy.distance.geodesic((l_lat, l_long),(r_lat, r_long)).km,2)
                                        distances_dict['distance'][tuple([patllid,citllid])] = dist
                                    else:
                                        exp_citation8a += 1
                                        dist = distanceTreshold * 2 # just some value larger than the threshold, but not as high as validLargest. To indicate non local.
                            else:
                                exp_citation8b += 1

                            if dist < validLargest:
                                if dist < distanceTreshold:
                                    if ch == 0:
                                        exp_citation9a += 1
                                        patloc = citloc
                                    elif ch == 1:
                                        exp_citation9b += 1
                                        citloc = patloc
                                else:
                                    if ch == 0:
                                        exp_citation10a += 1
                                        patloc = validLargest # something that is different from citloc but not any other loc either
                                    elif ch == 1:
                                        exp_citation10b += 1
                                        citloc = validLargest # something that is different from patloc but not any other loc either
                            else:
                                exp_citation11 += 1 # distance was not set, same as exp_citation8b
                        else:
                            exp_citation12 += 1

                    if patloc < 0:
                        exp_citation13 += 1
                    if citloc < 0:
                        exp_citation14 += 1
                    if patloc < 0 or citloc < 0:
                        exp_citation15 += 1

                    if patass < 0:
                        exp_citation16 += 1
                    if citass < 0:
                        exp_citation17 += 1
                    if patass < 0 or citass < 0:
                        exp_citation18 += 1

                    if patloc < 0 or citloc < 0 or patass < 0 or citass < 0:
                        exp_citation19 += 1

                    erkey = tuple([year, citloc])
                    if erkey in targetdict:
                        mapf = open(targetdict[erkey], 'a+', encoding='utf-8')
                        mapwriter = csv.writer(mapf)
                        mapwriter.writerow(citation)
                        mapf.close()




    if sreader.line_num >= status_line + 375000:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Raw = " + str([sreader.line_num, raw_citation1a, raw_citation1b, raw_citation1c, raw_citation2a, raw_citation2b, raw_citation2c, raw_citation3]) + " Exp = "  + str([exp_citation1, exp_citation2, exp_citation3, exp_citation4]) + " Dist = " + str([exp_citation5, exp_citation6, exp_citation7, exp_citation8a, exp_citation8b, exp_citation9a, exp_citation9b, exp_citation10a, exp_citation10b, exp_citation11, exp_citation12]) + " Missing = " + str([exp_citation13, exp_citation14, exp_citation15, exp_citation16, exp_citation17, exp_citation18, exp_citation19]) + " t1 = " + str(round(t1,2)))
        status_line = sreader.line_num
        counter += 1
        if counter < 0:
            break
    end = time.time()
    t1 += end - start

# dump final output
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Raw = " + str([sreader.line_num, raw_citation1a, raw_citation1b, raw_citation1c, raw_citation2a, raw_citation2b, raw_citation2c, raw_citation3]) + " Exp = "  + str([exp_citation1, exp_citation2, exp_citation3, exp_citation4]) + " Dist = " + str([exp_citation5, exp_citation6, exp_citation7, exp_citation8a, exp_citation8b, exp_citation9a, exp_citation9b, exp_citation10a, exp_citation10b, exp_citation11, exp_citation12]) + " Missing = " + str([exp_citation13, exp_citation14, exp_citation15, exp_citation16, exp_citation17, exp_citation18, exp_citation19]) + " t1 = " + str(round(t1,2)))

# 2019-02-28 21:42:18 Total = 91000027 InvErr = 16235262 AssErr = 17894175 t1 = 7272.67
