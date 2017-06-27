# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 05:48:51 2016

@author: aiyenggar
"""

import csv
from datetime import datetime
import math
from math import radians, cos, sin, asin, sqrt

runPrefix = ['', 'a.', 'e.', 'o.', 't.', 'n.']
runList = [3]
pathPrefix = "/Users/aiyenggar/datafiles/patents/" 

# 0-patent_id, 1-inventor_id, 2-region, 3-country_loc, 4-year, 5-date, 6-latitude, 7-longitude, 8-city_rawloc, 9-location_id
keysFile1=pathPrefix+"rawinventor_urban_areas.csv"

# 0-patent_id, 1-assignee_id 2-region, 3-country_loc
keysFile2=pathPrefix+"rawassignee_urban_areas.csv"

#0-country2, 1-country, 2-ipr_score
keysFile3=pathPrefix+"country2.country.ipr_score.csv"

#0-uuid,1-patent_id,2-citation_id,3-date,4-name,5-kind,6-country,7-category,8-sequence
searchFileName="uspatentcitation.csv"

forwardmapheader=["fc_year", "fc_region", "fc_total", "fc_sla", "fc_slap", "fc_slpa", "fc_slpap", "fc_sother", "fc_sregion_cnt", "fc_sdistance_cnt", "fc_sl", "fc_sa"]
forwardmapFileName="forwardmap.csv"

backwardmapheader=["bc_year", "bc_region", "bc_total", "bc_sla", "bc_slap", "bc_slpa", "bc_slpap", "bc_sother", "bc_sregion_cnt", "bc_sdistance_cnt", "bc_sl", "bc_sa" ]
backwardmapFileName="backwardmap.csv"

logFileName="log.csv"
citationsFileName="citations.year.csv"
geoFileName="geodistance.csv"

pheader=list(["region","year","patent_count","pool_patent_count","cat1","cat2","cat3","cat4","cat5","cat6","cat7","subcat11","subcat12","subcat13","subcat14","subcat15","subcat19","subcat21","subcat22","subcat23","subcat24","subcat25","subcat31","subcat32","subcat33","subcat39","subcat41","subcat42","subcat43","subcat44","subcat45","subcat46","subcat49","subcat51","subcat52","subcat53","subcat54","subcat55","subcat59","subcat61","subcat62","subcat63","subcat64","subcat65","subcat66","subcat67","subcat68","subcat69","subcat70","dcat1","dcat2","dcat3","dcat4","dcat5","dcat6","dcat7","dsubcat11","dsubcat12","dsubcat13","dsubcat14","dsubcat15","dsubcat19","dsubcat21","dsubcat22","dsubcat23","dsubcat24","dsubcat25","dsubcat31","dsubcat32","dsubcat33","dsubcat39","dsubcat41","dsubcat42","dsubcat43","dsubcat44","dsubcat45","dsubcat46","dsubcat49","dsubcat51","dsubcat52","dsubcat53","dsubcat54","dsubcat55","dsubcat59","dsubcat61","dsubcat62","dsubcat63","dsubcat64","dsubcat65","dsubcat66","dsubcat67","dsubcat68","dsubcat69","dsubcat70"])
patentsFile=pathPrefix+"urbanareas.year.csv"
    
outputheader=["year", "region", "patents", "pool", "cit_made_total", "cit_made_localinternal", "cit_made_localexternal", "cit_made_nonlocalinternal", "cit_made_nonlocalexternal", "cit_made_other", "cit_made_local", "cit_made_internal", "cit_made_region_cnt", "cit_made_distance_cnt", "cit_recd_total", "cit_recd_self", "cit_recd_nonself"]
outputFileName="citations.urbanareas.year.csv"
    
    

l3 = []
l3.append('')
l3.append('')
l3.append('')
ll3 = []
ll3.append(l3)

l10 = []
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
l10.append('')
ll10 = []
ll10.append(l10)

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

def dumpsimpledict(fName, dictionary, header):
    mapf = open(fName, 'w', encoding='utf-8')
    mapwriter = csv.writer(mapf)
    mapwriter.writerow(header)
    for key in dictionary:
        mapwriter.writerow([key, dictionary[key]])
    mapf.close()
    return

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
ilatitude = 6
ilongitude = 7
icity_rawloc = 8
ilocation_id = 9
icountry_loc = 10
for k1r in kreader1:
    if kreader1.line_num == 1:
        continue
    if (k1r[ipatent_id] not in iDict):
        iDict[k1r[ipatent_id]] = list([])
    iDict[k1r[ipatent_id]].append(k1r)
    if kreader1.line_num % 1000000 == 0:
        print("Read " + str(kreader1.line_num) + " patent inventor locations")
print("done reading rawinventor_region.csv to memory")
kreader1 = None
k1.close()

k2 = open(keysFile2, 'r', encoding='utf-8')
kreader2 = csv.reader(k2)
geoDict=dict({})
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

distancesDict=dict({})

for runno in runList:
    print("Starting with runno " + str(runno))
    searchFile=pathPrefix+runPrefix[runno]+searchFileName
    forwardmapFile=pathPrefix+runPrefix[runno]+forwardmapFileName
    backwardmapFile=pathPrefix+runPrefix[runno]+backwardmapFileName
    logFile=pathPrefix+runPrefix[runno]+logFileName
    citationsFile=pathPrefix+runPrefix[runno]+citationsFileName
    geoFile=pathPrefix+runPrefix[runno]+geoFileName
    
    
    indf = open(logFile, 'w', encoding='utf-8')
    indwriter = csv.writer(indf)
    indwriter.writerow(["ass_sim", "loc_sim", "cg_patent_id", "ct_patent_id", "ct_inventor_latitude", "ct_inventor_longigude", "cg_inventor_latitude", "cg_inventor_longigude", "ct_inventor_city", "cg_inventor_city", "cg_inventor_id", "cg_inventor_region", "cg_assignee_id", "cg_inventor_year", "ct_inventor_id", "ct_inventor_region", "ct_assignee_id", "ct_inventor_year"])
    
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
                icg_list = ll10
        else:
            icg_list = ll10
            #print("Citing " + cg_patent_id + " not found in the iDict dictionary")
               
        for next_entry in icg_list:
            cg_inventor_year = next_entry[iyear]
            try:
                yearint = int(cg_inventor_year)
                if yearint <= 2000:
                    continue
            except ValueError:
                continue

            cg_inventor_id = next_entry[iinventor_id]
            cg_inventor_region = next_entry[iregion]
            cg_inventor_country = next_entry[icountry]
            
            cg_inventor_date = next_entry[idate]
            cg_inventor_latitude = next_entry[ilatitude]
            cg_inventor_longigude = next_entry[ilongitude]
            cg_inventor_city = next_entry[icity_rawloc]
            cg_location_id = next_entry[ilocation_id]
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
                        ict_list = ll10
                else:
                    ict_list = ll10
                    #print("Cited " + ct_patent_id + " not found in the iDict dictionary")
                   
                for xt_entry in ict_list:
                    ct_inventor_id = xt_entry[iinventor_id]
                    ct_inventor_region = xt_entry[iregion]
                    ct_inventor_country = xt_entry[icountry]
                    ct_inventor_year = xt_entry[iyear]
                    ct_inventor_date = xt_entry[idate]
                    ct_inventor_latitude = xt_entry[ilatitude]
                    ct_inventor_longigude = xt_entry[ilongitude]
                    ct_inventor_city = xt_entry[icity_rawloc]
                    ct_location_id = xt_entry[ilocation_id]
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
    
    
                        distance_dummy = 2
                        loc_sim = 2 # indeterminate by default
                        if (len(ct_inventor_region) > 0 and len(cg_inventor_region) > 0):
                            distance_dummy = 0
                            if (ct_inventor_region == cg_inventor_region):
                                loc_sim = 1
                            else:
                                loc_sim = 0
                        else:
                            # Avoid calculating the distance if possible
                            if (len(ct_inventor_country) > 0 and len(cg_inventor_country) > 0 and ct_inventor_country != cg_inventor_country):
                                distance_dummy = 1
                                loc_sim = 0
                            else:
                                if (len(ct_location_id) > 0 and len(cg_location_id) > 0):
                                    if ct_location_id <= cg_location_id:
                                        lockey = ct_location_id + ", " + cg_location_id
                                    else:
                                        lockey = cg_location_id + ", " + ct_location_id
                                    if lockey not in distancesDict:
                                        distancesDict[lockey] = haversine(ct_inventor_longigude, ct_inventor_latitude, cg_inventor_longigude, cg_inventor_latitude)
                                    distkm = distancesDict[lockey]
                                else:
                                    distkm = haversine(ct_inventor_longigude, ct_inventor_latitude, cg_inventor_longigude, cg_inventor_latitude)
                                distance_dummy = 1
                                if distkm <= 50:
                                    loc_sim = 1
                                else:
                                    loc_sim = 0
                                if (len(ct_inventor_city) > 0 and len(cg_inventor_city) > 0):
                                    if ct_inventor_city <= cg_inventor_city:
                                        geokey = ct_inventor_city + "," + cg_inventor_city + "," + str(round(distkm)) 
                                    else:
                                        geokey = cg_inventor_city + "," + ct_inventor_city + "," + str(round(distkm)) 
                                    if geokey not in geoDict:
                                        geoDict[geokey] = 1
                                    else:
                                        geoDict[geokey] = geoDict[geokey] + 1
                                
                                 
    #                    indwriter.writerow([ass_sim, loc_sim, cg_patent_id, ct_patent_id, ct_inventor_latitude, ct_inventor_longigude, cg_inventor_latitude, cg_inventor_longigude, ct_inventor_city, cg_inventor_city, cg_inventor_id, cg_inventor_region, cg_assignee_id, cg_inventor_year, ct_inventor_id, ct_inventor_region, ct_assignee_id, ct_inventor_year])
    
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
                        mkey.append(ct_assignee_id)
                        mkey.append(cg_assignee_id)
    
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
    
                            if distance_dummy != 2:
                                if distance_dummy == 0:
                                    region_cnt = 1
                                    distance_cnt = 0
                                else:
                                    region_cnt = 0
                                    distance_cnt = 1
                            else:
                                region_cnt = 0
                                distance_cnt = 0
    
                            if (len(ct_inventor_region) > 0 and len(ct_inventor_year) > 0):
                                nkey = []
                                nkey.append(ct_inventor_year) 
                                # ct_inventor_year will capture the vintage
                                # Citing inventor year was used previously
                                nkey.append(ct_inventor_region)
                                ntkey = tuple(nkey)
                                if ntkey not in forwardCitations:
                                    forwardCitations[ntkey] = [1, la, lap, lpa, lpap, other, region_cnt, distance_cnt]
                                else:
                                    prev = forwardCitations[ntkey]
                                    total = prev[0] + 1
                                    sla = prev[1] + la
                                    slap = prev[2] + lap
                                    slpa = prev[3] + lpa
                                    slpap = prev[4] + lpap
                                    sother = prev[5] + other
                                    sregion_cnt = prev[6] + region_cnt
                                    sdistance_cnt = prev[7] + distance_cnt
                                    forwardCitations[ntkey] = [total, sla, slap, slpa, slpap, sother, sregion_cnt, sdistance_cnt]
                            
                            if (len(cg_inventor_region) > 0 and ass_sim != 2 and loc_sim != 2):
                                nkey = []
                                nkey.append(cg_inventor_year)
                                nkey.append(cg_inventor_region)
                                ntkey = tuple(nkey)
                                if ntkey not in backwardCitations:
                                    backwardCitations[ntkey] = [1, la, lap, lpa, lpap, other, region_cnt, distance_cnt]
                                else:
                                    prev = backwardCitations[ntkey]
                                    total = prev[0] + 1
                                    sla = prev[1] + la
                                    slap = prev[2] + lap
                                    slpa = prev[3] + lpa
                                    slpap = prev[4] + lpap
                                    sother = prev[5] + other
                                    sregion_cnt = prev[6] + region_cnt
                                    sdistance_cnt = prev[7] + distance_cnt
                                    backwardCitations[ntkey] = [total, sla, slap, slpa, slpap, sother, sregion_cnt, sdistance_cnt]
    
        if sreader.line_num % 1000000 == 0:
            dump(forwardmapFile, forwardCitations, forwardmapheader)
            dump(backwardmapFile, backwardCitations, backwardmapheader)
            dumpsimpledict(citationsFile, yearCitations, ["year", "citations"])
            dumpsimpledict(geoFile, geoDict, ["source-destination", "count"])
            #before = len(geoDict)
            #delkeys = []
            #for k, v in geoDict.items():
                #if (v <= 1):
                    #delkeys.append(k)
            #for key in delkeys:
                #del(geoDict[key])
            #after = len(geoDict)
            #print("Cleaned up geoDict. Before " + str(before) + " After " + str(after))
        if sreader.line_num % 1000000 == 0:
            print("Processed " + str(sreader.line_num) + " lines")
    
    indf.close()
    dump(forwardmapFile, forwardCitations, forwardmapheader)
    dump(backwardmapFile, backwardCitations, backwardmapheader)
    print("Processed all")
    searchf.close()
    print("Closed searchf")
    dumpsimpledict(citationsFile, yearCitations, ["year", "citations"])
    dumpsimpledict(geoFile, geoDict, ["source-destination", "count"])
    
    
    
    fmapFile=forwardmapFile
    bmapFile=backwardmapFile
    outputFile=pathPrefix+runPrefix[runno]+outputFileName

    pDict = dict({})
    patentsf = open(patentsFile, 'r', encoding='utf-8')
    patentsr = csv.reader(patentsf)
    
    for patentsl in patentsr:
        if patentsr.line_num == 1:
            continue
        l = []
        l.append(patentsl[1]) #year
        l.append(patentsl[0]) #region
        pkey = tuple(l)
        if pkey not in pDict:
            pDict[pkey] = patentsl #saving the whole line
        else:
            print("Duplicate in patentsFile " + str(pkey))
    print("finished reading in patentsFile")
    
    fDict = dict({})
    forwardf = open(fmapFile, 'r', encoding='utf-8')
    forwardr = csv.reader(forwardf)
    for forwardl in forwardr:
        if forwardr.line_num == 1:
            continue
        if not forwardl[0].isdigit():
            print("In Forward Citations, Skipping " + str(forwardl))
            continue # skip header lines
        l = []
        l.append(forwardl[0])
        l.append(forwardl[1])
        fkey = tuple(l)
        
        if fkey not in fDict:
            fDict[fkey] = forwardl
        else:
            print("Duplicate forwardl entry for " + fkey)
        if forwardr.line_num % 5000 == 0:
            print("Processed " + str(forwardr.line_num) + " forward citation lines")    
    
    
    bDict = dict({})
    backwardf = open(bmapFile, 'r', encoding='utf-8')
    backwardr = csv.reader(backwardf)
    for backwardl in backwardr:
        if backwardr.line_num == 1:
            continue
        if not backwardl[0].isdigit():
            print("In Backward Citations, Skipping " + str(backwardl))
            continue # skip header lines
        l = []
        l.append(backwardl[0])
        l.append(backwardl[1])
        bkey = tuple(l)
        
        if bkey not in bDict:
            bDict[bkey] = backwardl
        else:
            print("Duplicate backwardl entry for " + bkey)
        if backwardr.line_num % 5000 == 0:
            print("Processed " + str(backwardr.line_num) + " backward citation lines")  
    
    outputf = open(outputFile, 'w', encoding='utf-8')
    writer = csv.writer(outputf)
    writer.writerow(outputheader+pheader[4:])
    
    for p in pDict:
        year = p[0]
        region = p[1]
        
        pv = pDict[p]
        patents = pv[2]
        pool = pv[3]
        dummies = pv[4:]
        
        if p in bDict:
            bv = bDict[p]
        else:
            bv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        cit_made_total = bv[2]
        cit_made_localinternal = bv[3]
        cit_made_localexternal = bv[4]
        cit_made_nonlocalinternal = bv[5]
        cit_made_nonlocalexternal = bv[6]
        cit_made_other = bv[7]
        cit_made_region_cnt = bv[8]
        cit_made_distance_cnt = bv[9]
        cit_made_local = bv[10]
        cit_made_internal = bv[11]
    
        if p in fDict:
            fv = fDict[p]
        else:
            fv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        cit_recd_total = fv[2]
        cit_recd_self = int(fv[3]) + int(fv[5])
        cit_recd_nonself = int(fv[4]) + int(fv[6]) + int(fv[7])
    
        baserow = [year, region, patents, pool, cit_made_total, cit_made_localinternal, cit_made_localexternal, cit_made_nonlocalinternal, cit_made_nonlocalexternal, cit_made_other, cit_made_local, cit_made_internal, cit_made_region_cnt, cit_made_distance_cnt, cit_recd_total, cit_recd_self, cit_recd_nonself]
        writer.writerow(baserow+dummies)
    
    outputf.close()
    print("Ending with runno " + str(runno))
exit()
