"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import pandas as pd
import time
import geopy.distance
import citationutils as ut

def getDistance(latlong1, latlong2):
    retVal = ut.veryLargeValue
    key1 = tuple([latlong1, latlong2])
    key2 = tuple([latlong2, latlong1])
    if key1 in distances_dict['distance']:
        retVal = distances_dict['distance'][key1]
    elif key2 in distances_dict['distance']:
        retVal = distances_dict['distance'][key2]
    else:
        l_lat = latlong_dict['latitude'][latlong1]
        l_long = latlong_dict['longitude'][latlong1]
        r_lat = latlong_dict['latitude'][latlong2]
        r_long = latlong_dict['longitude'][latlong2]
        if (l_lat < r_lat + ut.degreeTreshold) and (l_lat > r_lat - ut.degreeTreshold) and (l_long < r_long + ut.degreeTreshold) and (l_long > r_long - ut.degreeTreshold):
            retVal = round(geopy.distance.geodesic((l_lat, l_long),(r_lat, r_long)).km,2)
            distances_dict['distance'][key1] = retVal
    return retVal

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
summary_dict = pd.read_csv(ut.summaryFile, usecols = ['patent_id','cited_type1','cited_type2','cited_type3','cited_type4','cited_type5','precutoff_patents_cited','all_patents_cited','cnt_assignee','cnt_inventor'], dtype={'patent_id':str,'cited_type1':int,'cited_type2':int,'cited_type3':int,'cited_type4':int,'cited_type5':int,'precutoff_patents_cited':int,'all_patents_cited':int,'cnt_assignee':int,'cnt_inventor':int}, index_col='patent_id').to_dict()

inv_uaid_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','ualist'], dtype={'patent_id':str,'ualist':str}, index_col='patent_id').to_dict()
assignee_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','assigneelist'], dtype={'patent_id':str,'assigneelist':str}, index_col='patent_id').to_dict()
inv_latlongid_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','latlonglist'], dtype={'patent_id':str,'latlonglist':str}, index_col='patent_id').to_dict()

if ut.calculateCitationDistance:
    dist_df = pd.read_csv(ut.distancesFile, usecols = ['l_latlongid','r_latlongid','distance'], dtype={'l_latlongid':int,'r_latlongid':int,'distance':float})
    dist_df.sort_values(by=['l_latlongid','r_latlongid'], inplace=True)
    dist_df['lr']=list(zip(dist_df.l_latlongid, dist_df.r_latlongid))
    dist_df.drop(columns=['l_latlongid','r_latlongid'], inplace=True)
    dist_df.set_index('lr', inplace=True)
    distances_dict = dist_df.to_dict()
    latlong_dict = pd.read_csv(ut.latlongFile, usecols = ['latlongid','latitude','longitude'], dtype={'latlongid':int,'latitude':float,'longitude':float}, index_col='latlongid').to_dict()
else:
    distances_dict = None
    latlong_dict = None

total_citrecd = {}
self_citrecd = {}
nonself_citrecd = {}
searchf = open(ut.searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")
outputFileNumber = 0
for citation in sreader:
    if sreader.line_num == 1:
        outputFileNumber += 1
        mapf = open(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-made-" + str(outputFileNumber) + ".csv", 'w', encoding='utf-8')
        mapwriter = csv.writer(mapf)
        mapwriter.writerow(["year", "m_patent_id", "m_inventor_uaid", "m_assignee_id", "r_patent_id", "r_inventor_uaid", "r_assignee_id", "citation_type"])
        continue # we skip the header line
    if sreader.line_num >= last_time + ut.update_freq_lines:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num) + " raw citations")
        last_time = sreader.line_num
        mapf.close()
        outputFileNumber += 1
        mapf = open(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-made-" + str(outputFileNumber) + ".csv", 'w', encoding='utf-8')
        mapwriter = csv.writer(mapf)
        mapwriter.writerow(["year", "m_patent_id", "m_inventor_uaid", "m_assignee_id", "r_patent_id", "r_inventor_uaid", "r_assignee_id", "citation_type"])
    try:
        year = int(citation[0])
    except ValueError:
        continue
    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    if (len(patent_id) == 0) or (len(citation_id) == 0):
        continue
    type_citation = int(citation[3]) # 1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party
    seq_citation = int(citation[4])
    kind_citation = citation[5] # B1, A etc

    p_latlongid = ut.splitFromDict(patent_id, "latlonglist", ",", inv_latlongid_dict)
    p_loc = ut.splitFromDict(patent_id, "ualist", ",", inv_uaid_dict)
    p_ass = ut.splitFromDict(patent_id, "assigneelist", ",", assignee_dict)

    c_latlongid = ut.splitFromDict(citation_id, "latlonglist", ",", inv_latlongid_dict)
    c_loc = ut.splitFromDict(citation_id, "ualist", ",", inv_uaid_dict)
    c_ass = ut.splitFromDict(citation_id, "assigneelist", ",", assignee_dict)

    for pind in range(len(p_loc)):
        for cind in range(len(c_loc)):
            for apind in range(len(p_ass)):
                for acind in range(len(c_ass)):
                    patllid = int(p_latlongid[pind])
                    patloc = int(p_loc[pind])
                    patass = int(p_ass[apind])

                    citllid = int(c_latlongid[cind])
                    citloc = int(c_loc[cind])
                    citass = int(c_ass[acind])

                    if ut.calculateCitationDistance and ut.isValidLatLongId(patllid) and ut.isValidLatLongId(citllid):
                        if ut.isValidUrbanArea(patloc) and (not ut.isValidUrbanArea(citloc)):
                            if (getDistance(patllid, citllid) < ut.distanceTreshold):
                                citloc = patloc
                        if ut.isValidUrbanArea(citloc) and (not ut.isValidUrbanArea(patloc)):
                            if (getDistance(patllid, citllid) < ut.distanceTreshold):
                                patloc = citloc

                    mapwriter.writerow([year, patent_id, patloc, patass, citation_id, citloc, citass, type_citation])

searchf.close()
mapf.close()
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
