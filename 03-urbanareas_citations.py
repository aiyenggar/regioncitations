# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 05:48:51 2016

@author: aiyenggar
"""

import csv
from datetime import datetime
import math

def dump(fName, dictionary, header):
    mapf = open(fName, 'w', encoding='utf-8')
    mapwriter = csv.writer(mapf)
    mapwriter.writerow(header)
    for key in dictionary:
        l = list(key)
        r = list(dictionary[key])
        sl = r[1] + r[2]
        sa = r[1] + r[3]
        t = [sl, sa]
        mapwriter.writerow(l+r+t)
    mapf.close()
    return

def getname(base, number, extension):
    return base + str(number) + extension
    
def years(fromdate, todate):
    try:
        dt1=datetime.strptime(todate, '%Y-%m-%d')
        dt2=datetime.strptime(fromdate, '%Y-%m-%d')
    except ValueError:
        return None
    return math.floor(((dt1 - dt2).days)/365.2425)

# 0-patent_id, 1-inventor_id, 2-region, 3-country_loc, 4-year, 5-date
keysFile1="/Users/aiyenggar/datafiles/patents/rawinventor_urban_areas.csv"

# 0-patent_id, 1-assignee_id 2-region, 3-country_loc
keysFile2="/Users/aiyenggar/datafiles/patents/rawassignee_urban_areas.csv"

#0-country2, 1-country, 2-ipr_score
keysFile3="/Users/aiyenggar/datafiles/patents/country2.country.ipr_score.csv"

#0-uuid,1-patent_id,2-citation_id,3-date,4-name,5-kind,6-country,7-category,8-sequence
searchFile1="/Users/aiyenggar/datafiles/patents/uspatentcitation.applicant.examiner.csv"
searchFile2="/Users/aiyenggar/datafiles/patents/uspatentcitation.examiner.csv"
searchFile3="/Users/aiyenggar/datafiles/patents/uspatentcitation.applicant.csv"

forwardmapheader=["fc_year", "fc_region", "fc_total", "fc_sla", "fc_slap", "fc_slpa", "fc_slpap", "fc_sother", "fc_sl", "fc_sa"]
forwardmapFile1="/Users/aiyenggar/datafiles/patents/ae.forwardmap.csv"
forwardmapFile2="/Users/aiyenggar/datafiles/patents/e.forwardmap.csv"
forwardmapFile3="/Users/aiyenggar/datafiles/patents/a.forwardmap.csv"

backwardmapheader=["bc_year", "bc_region", "bc_total", "bc_sla", "bc_slap", "bc_slpa", "bc_slpap", "bc_sother", "bc_sl", "bc_sa"]
backwardmapFile1="/Users/aiyenggar/datafiles/patents/ae.backwardmap.csv"
backwardmapFile2="/Users/aiyenggar/datafiles/patents/e.backwardmap.csv"
backwardmapFile3="/Users/aiyenggar/datafiles/patents/a.backwardmap.csv"

searchFile=searchFile3
forwardmapFile=forwardmapFile3
backwardmapFile=backwardmapFile3

l7 = []
l7.append('')
l7.append('')
l7.append('')
l7.append('')
l7.append('')
l7.append('')
l7.append('')
ll7 = []
ll7.append(l7)

"""
l5 = []
l5.append('')
l5.append('')
l5.append('')
l5.append('')
l5.append('')
ll5 = []
ll5.append(l5)

l4 = []
l4.append('')
l4.append('')
l4.append('')
l4.append('')
ll4 = []
ll4.append(l4)
"""

l3 = []
l3.append('')
l3.append('')
l3.append('')
ll3 = []
ll3.append(l3)

k1 = open(keysFile1, 'r', encoding='utf-8')
kreader1 = csv.reader(k1)

# Read the entire keysFile1 to memory
# Keyed on patent-id, pull out a list of all inventors and their asociated regions
iDict=dict({})
ipatent_id = 0
iinventor_id = 1
iregion = 2
icountry = 3
iyear = 4
idate = 5
for k1r in kreader1:
    if kreader1.line_num == 1:
        continue
    if (k1r[ipatent_id] not in iDict):
        iDict[k1r[ipatent_id]] = list([])
    iDict[k1r[ipatent_id]].append([k1r[iinventor_id],k1r[iregion],k1r[icountry],k1r[iyear],k1r[idate]])
    if kreader1.line_num % 1000000 == 0:
        print("Read " + str(kreader1.line_num) + " patent inventor locations")
print("done reading rawinventor_region.csv to memory")
kreader1 = None
k1.close()

k2 = open(keysFile2, 'r', encoding='utf-8')
kreader2 = csv.reader(k2)

# Read the entire keysFile2 to memory
# Keyed on patent-id, retrieve a list of all assignee-id and associated region
aDict=dict({})
ipatent_id = 0
iassignee_id = 1
iregion = 2
icountry = 3
for k2r in kreader2:
    if kreader2.line_num == 1:
        continue
    if (k2r[ipatent_id] not in aDict):
        aDict[k2r[ipatent_id]] = list([])
    aDict[k2r[ipatent_id]].append([k2r[iassignee_id],k2r[iregion],k2r[icountry]])
    if kreader2.line_num % 1000000 == 0:
        print("Read " + str(kreader2.line_num) + " assignee locations")
print("done reading rawassignee_region.csv to memory")
kreader2 = None
k2.close()

k3 = open(keysFile3, 'r', encoding='utf-8')
kreader3 = csv.reader(k3)

# Read the entire keysFile3 to memory
# Keyed on 2 digit country code, retrieve ipr score
cDict=dict({})
icountry2 = 0
icountry = 1 
iipr_score = 2
for k3r in kreader3:
    if kreader3.line_num == 1:
        continue
    if (k3r[icountry2] not in cDict):
        cDict[k3r[icountry2]] = k3r[iipr_score]
    else:
        print("Repeating country " + k3r[icountry2] + " in country_ipr.csv, Skipping")
print("done reading country_ipr.csv to memory")
kreader3 = None
k3.close()

searchf = open(searchFile, 'r', encoding='utf-8')
sreader = csv.reader(searchf)

lDict=dict({})
forwardCitations=dict({})
backwardCitations=dict({})
yearCitations=dict({})

for entry in sreader:
    if sreader.line_num == 1:
        continue

    cit_uuid = entry[0]
    cg_patent_id = entry[1]
    ct_patent_id = entry[2]
    icg_list = None
    #Loop 1
    if (cg_patent_id in iDict): 
        icg_list = iDict[cg_patent_id] 
        if (len(icg_list) == 0):
            #print("Citing " + cg_patent_id + " of length 0 in iDict dictionary")
            icg_list = ll7
    else:
        icg_list = ll7
        #print("Citing " + cg_patent_id + " not found in the iDict dictionary")
           
    for next_entry in icg_list:
        cg_inventor_id = next_entry[0]
        cg_inventor_region = next_entry[1]
        cg_inventor_country = next_entry[2]
        cg_inventor_year = next_entry[3]
        cg_inventor_date = next_entry[4]
        acg_list = None
        #Loop 2
        if (cg_patent_id in aDict):
            acg_list = aDict[cg_patent_id]
            if (len(acg_list) == 0):
                #print("Citing " + cg_patent_id + " of length 0 in aDict dictionary")
                acg_list = ll3
        else:
            acg_list = ll3
            #print("Citing " + cg_patent_id + " not found in aDict dictionary")
           
        for ext_entry in acg_list:
            cg_assignee_id = ext_entry[0]
            cg_assignee_region = ext_entry[1]
            cg_assignee_country = ext_entry[2]
            ict_list = None   
            #Loop 3
            if (ct_patent_id in iDict): 
                ict_list = iDict[ct_patent_id] 
                if (len(ict_list) == 0):
                    #print("Cited " + ct_patent_id + " of length 0 in iDict dictionary")
                    ict_list = ll7
            else:
                ict_list = ll7
                #print("Cited " + ct_patent_id + " not found in the iDict dictionary")
               
            for xt_entry in ict_list:
                ct_inventor_id = xt_entry[0]
                ct_inventor_region = xt_entry[1]
                ct_inventor_country = xt_entry[2]
                ct_inventor_year = xt_entry[3]
                ct_inventor_date = xt_entry[4]
                act_list = None
                #Loop 4
                if (ct_patent_id in aDict):
                    act_list = aDict[ct_patent_id]
                    if (len(act_list) == 0):
                        #print("Cited " + ct_patent_id + " of length 0 in aDict dictionary")
                        act_list = ll3
                else:
                    act_list = ll3
                    #print("Cited " + ct_patent_id + " not found in aDict dictionary")
                for t_entry in act_list:
                    ct_assignee_id = t_entry[0]
                    ct_assignee_region = t_entry[1]
                    ct_assignee_country = t_entry[2]
                   
                    # We are now ready to write a line
                   
                    # Accumulate citations only till 5 years
                    delta = years(ct_inventor_date, cg_inventor_date)
                    """
                    if delta == None or delta >= 5:
                        continue
                    """
                    ass_sim = 2 # indeterminate by default
                    if (len(cg_assignee_id) > 0 and len(ct_assignee_id) > 0):
                         if (cg_assignee_id == ct_assignee_id):
                             ass_sim = 1
                         else:
                             ass_sim = 0
                    loc_sim = 2 # indeterminate by default
                    if (len(ct_inventor_region) > 0 and len(cg_inventor_region) > 0):
                         if (ct_inventor_region == cg_inventor_region):
                             loc_sim = 1
                         else:
                             loc_sim = 0
                    if (cg_assignee_country in cDict):
                        cg_assignee_ipr = cDict[cg_assignee_country]
                    else:
                        cg_assignee_ipr = ''
                    if (ct_assignee_country in cDict):
                        ct_assignee_ipr = cDict[ct_assignee_country]
                    else:
                        ct_assignee_ipr = ''
                    if (cg_inventor_country in cDict):
                        cg_inventor_ipr = cDict[cg_inventor_country]
                    else:
                        cg_inventor_ipr = ''
                    if (ct_inventor_country in cDict):
                        ct_inventor_ipr = cDict[ct_inventor_country]
                    else:
                        ct_inventor_ipr = ''
                       
                    mkey = []
                    mkey.append(ct_patent_id)
                    mkey.append(cg_patent_id)
                    mkey.append(ct_inventor_region)
                    mkey.append(cg_inventor_region)
                    mkey.append(ass_sim)
                    tkey = tuple(mkey)
                    # Look at one region-region only once per patent-patent citation
                    if tkey not in lDict:
                        if cg_inventor_year not in yearCitations:
                            yearCitations[cg_inventor_year] = 1
                        else:
                            yearCitations[cg_inventor_year] = yearCitations[cg_inventor_year] + 1
                        lDict[tkey] = 1
                        # Calculate location assignee similarity
                        if (loc_sim == 1 and ass_sim == 1):
                            la = 1
                        else:
                            la = 0
                        if (loc_sim == 1 and ass_sim == 0):
                            lap = 1
                        else:
                            lap = 0
                        if (loc_sim == 0 and ass_sim == 1):
                            lpa = 1
                        else:
                            lpa = 0
                        if (loc_sim == 0 and ass_sim == 0):
                            lpap = 1
                        else:
                            lpap = 0
                        if (loc_sim == 2 or ass_sim == 2):
                            other = 1
                        else:
                            other = 0
                        nkey = []
                        nkey.append(ct_inventor_year) 
                        # ct_inventor_year will capture the vintage
                        # Citing inventor year was used previously
                        nkey.append(ct_inventor_region)
                        ntkey = tuple(nkey)
                        if ntkey not in forwardCitations:
                            forwardCitations[ntkey] = [1, la, lap, lpa, lpap, other]
                        else:
                            prev = forwardCitations[ntkey]
                            total = prev[0] + 1
                            sla = prev[1] + la
                            slap = prev[2] + lap
                            slpa = prev[3] + lpa
                            slpap = prev[4] + lpap
                            sother = prev[5] + other
                            forwardCitations[ntkey] = [total, sla, slap, slpa, slpap, sother]
                            
                        nkey = []
                        nkey.append(cg_inventor_year)
                        nkey.append(cg_inventor_region)
                        ntkey = tuple(nkey)
                        if ntkey not in backwardCitations:
                            backwardCitations[ntkey] = [1, la, lap, lpa, lpap, other]
                        else:
                            prev = backwardCitations[ntkey]
                            total = prev[0] + 1
                            sla = prev[1] + la
                            slap = prev[2] + lap
                            slpa = prev[3] + lpa
                            slpap = prev[4] + lpap
                            sother = prev[5] + other
                            backwardCitations[ntkey] = [total, sla, slap, slpa, slpap, sother]

    if sreader.line_num % 1000000 == 0:
        dump(forwardmapFile, forwardCitations, forwardmapheader)
        dump(backwardmapFile, backwardCitations, backwardmapheader)
        if len(yearCitations)>0:
            errorf = open("citations.year.csv", 'w', encoding='utf-8')
            writer = csv.writer(errorf)
            for year in yearCitations:
                writer.writerow([year, yearCitations[year]])
            errorf.close()
    if sreader.line_num % 1000000 == 0:
        print("Processed " + str(sreader.line_num) + " lines")

dump(forwardmapFile, forwardCitations, forwardmapheader)
dump(backwardmapFile, backwardCitations, backwardmapheader)
print("Processed all")
searchf.close()
print("Closed searchf")

if len(yearCitations)>0:
    errorf = open("citations.year.csv", 'w', encoding='utf-8')
    writer = csv.writer(errorf)
    for year in yearCitations:
        writer.writerow([year, yearCitations[year]])
    errorf.close()