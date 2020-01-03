#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 19:38:36 2019

@author: aiyenggar
"""
import citationutils as ut
import csv
import pandas as pd
import time
import geopy.distance

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
summary_dict = pd.read_csv(ut.summaryFile, usecols = ['patent_id','cited_type1','cited_type2','cited_type3','cited_type4','cited_type5','precutoff_patents_cited','all_patents_cited','cnt_assignee','cnt_inventor','application_year'], dtype={'patent_id':str,'cited_type1':int,'cited_type2':int,'cited_type3':int,'cited_type4':int,'cited_type5':int,'precutoff_patents_cited':int,'all_patents_cited':int,'cnt_assignee':int,'cnt_inventor':int,'application_year':int}, index_col='patent_id').to_dict()

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
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")

distf = open(ut.citationDistanceUsedFileName, 'w', encoding='utf-8')
distwriter = csv.writer(distf)
distwriter.writerow(["category", "p_uaid", "c_uaid", "p_llid", "c_llid", "distance"])

searchf = open(ut.searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
last_index = 0
allflowslist = []

for citation in sreader:
    if sreader.line_num == 1:
        flowsDict = {}
        previous_patent = citation[1].strip()
        continue # we skip the header line

    if sreader.line_num >= last_time + ut.update_freq_lines + 1:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num - 1) + " raw citations")
        last_time = sreader.line_num
        last_index += 1
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Creating DataFrame")
        df = pd.DataFrame(allflowslist).rename(columns={0:'uaid', 1:'patent_id', 2:'citation_id', 3:'q1', 4:'q2', 5:'q3', 6:'q4', 7:'q5',8:'q6',9:'year'})
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Creating DataFrame")
        df.to_parquet(ut.singleUaidFlowsFile % last_index, compression='gzip')
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Writing " + ut.singleUaidFlowsFile % last_index)
        allflowslist = []
        distf.flush()

    try:
        year = int(citation[0])
    except ValueError:
        continue
    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    if (len(patent_id) == 0): # We now place len(citation_id) == 0 into q6
        continue
    
    if previous_patent != patent_id: #seeing a new patent_id, flush the dictionary
        allflowslist += [list(k) + list(v) for k,v in flowsDict.items()]
        flowsDict = {}
        previous_patent = patent_id
    try:
        type_citation = int(citation[3]) # 1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party
    except ValueError:
        type_citation = ut.keyErrorValue[0]
    try:
        seq_citation = int(citation[4])
    except ValueError:
        seq_citation = ut.keyErrorValue[0]
            
    kind_citation = citation[5] # B1, A etc
    
    try:
        citation_application_year = int(citation[6])
    except ValueError:
        citation_application_year = ut.keyErrorValue[0] # We can go on

    p_latlongid = ut.splitFromDict(patent_id, "latlonglist", ",", inv_latlongid_dict)
    p_loc = ut.splitFromDict(patent_id, "ualist", ",", inv_uaid_dict)
    p_ass = ut.splitFromDict(patent_id, "assigneelist", ",", assignee_dict)

    c_latlongid = ut.splitFromDict(citation_id, "latlonglist", ",", inv_latlongid_dict)
    c_loc = ut.splitFromDict(citation_id, "ualist", ",", inv_uaid_dict)
    c_ass = ut.splitFromDict(citation_id, "assigneelist", ",", assignee_dict)

    p_count_patents_cited_type1 = ut.readDict(patent_id, 'cited_type1', summary_dict)
    p_count_patents_cited_type2 = ut.readDict(patent_id, 'cited_type2', summary_dict)
    p_count_patents_cited_type3 = ut.readDict(patent_id, 'cited_type3', summary_dict)
    p_count_patents_cited_type4 = ut.readDict(patent_id, 'cited_type4', summary_dict)
    p_count_patents_cited_type4 = ut.readDict(patent_id, 'cited_type5', summary_dict)
    p_count_patents_cited_all = ut.readDict(patent_id, 'all_patents_cited', summary_dict) 
    p_count_assignees = ut.readDict(patent_id, 'cnt_assignee', summary_dict)
    p_count_inventors = ut.readDict(patent_id, 'cnt_inventor', summary_dict)
    c_count_assignees = ut.readDict(citation_id, 'cnt_assignee', summary_dict)
    c_count_inventors = ut.readDict(citation_id, 'cnt_inventor', summary_dict)
    c_application_year = ut.readDict(citation_id, 'application_year', summary_dict)
    
    for pind in range(len(p_loc)):
        patllid = int(p_latlongid[pind])
        patloc = int(p_loc[pind])
        if not ut.isValidUrbanArea(patloc):
            continue
        pflow = [-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        divisor = 1
        if p_count_patents_cited_all > 1:
            divisor *= p_count_patents_cited_all
        if p_count_assignees > 1:
            divisor *= p_count_assignees
        if c_count_assignees > 1:
            divisor *= c_count_assignees
        if p_count_inventors > 1:
            divisor *= p_count_inventors
        if c_count_inventors > 1:
            divisor *= c_count_inventors
        flow_value = 1/divisor
        
        if p_count_patents_cited_all == 0: # we found a patent that did not cite any other
            quadrant = 6
            pflow[quadrant] = flow_value
        else:        
            for cind in range(len(c_loc)):
                citllid = int(c_latlongid[cind])
                citloc = int(c_loc[cind])
                for apind in range(len(p_ass)):
                    patass = int(p_ass[apind])
                    for acind in range(len(c_ass)):
                        citass = int(c_ass[acind])
    
                        if ut.calculateCitationDistance and ut.isValidLatLongId(patllid) and ut.isValidLatLongId(citllid):
                            if ut.isValidUrbanArea(patloc) and (not ut.isValidUrbanArea(citloc)):
                                dt = getDistance(patllid, citllid)
                                if (dt < ut.distanceTreshold):
                                    distwriter.writerow(['C', patloc, citloc, patllid, citllid, dt])
                                    citloc = patloc
                            if ut.isValidUrbanArea(citloc) and (not ut.isValidUrbanArea(patloc)):
                                dt = getDistance(patllid, citllid)
                                if (dt < ut.distanceTreshold):
                                    distwriter.writerow(['P', patloc, citloc, patllid, citllid, dt])
                                    patloc = citloc
    
                        if (c_application_year < 1976): # includes missing citation_years
                            quadrant = 5
                        elif (not ut.isValidAssignee(patass)) and (not ut.isValidAssignee(citass)):
                            quadrant = 5
                        else:
                            if patloc == citloc: # same urban area
                                if patass == citass: # same assignee
                                    quadrant = 1
                                else: # different assignee
                                    quadrant = 2
                            else: # different urban area
                                if patass == citass: # same assignee
                                    quadrant = 3
                                else: # different assignee
                                    quadrant = 4
                        pflow[quadrant] += flow_value
        roundedflow = [round(x,8) for x in pflow]
        k1 = tuple([patloc, patent_id, citation_id])
        if k1 not in flowsDict:
            flowsDict[k1] =  roundedflow[1:] + [year]
        else:
            priorflow = flowsDict[k1][:5]
            sumflow = [priorflow[i] + roundedflow[i+1] for i in range(len(priorflow))]
            flowsDict[k1] = sumflow + [year]

allflowslist += [list(k) + list(v) for k,v in flowsDict.items()]
flowsDict = {}
previous_patent = patent_id
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num - 1) + " raw citations")
last_time = sreader.line_num
last_index += 1
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Creating DataFrame")
df = pd.DataFrame(allflowslist).rename(columns={0:'uaid', 1:'patent_id', 2:'citation_id', 3:'q1', 4:'q2', 5:'q3', 6:'q4', 7:'q5',8:'q6',9:'year'})
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Creating DataFrame")
df.to_parquet(ut.singleUaidFlowsFile % last_index, compression='gzip')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Writing " + ut.singleUaidFlowsFile % last_index)
allflowslist = []
distf.flush()
    
searchf.close()
distf.close()
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
