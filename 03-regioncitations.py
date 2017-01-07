# -*- coding: utf-8 -*-
"""
Created on Fri Jan  7 05:48:51 2017

@author: aiyenggar
"""

import csv

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
    
kheader=list(["cg_patent_id", "cg_inventor_year",  "cg_inventor_id", "cg_inventor_region", "cg_inventor_country", "cg_inventor_ipr", "ct_patent_id", "ct_inventor_year", "ct_inventor_id", "ct_inventor_region", "ct_inventor_country", "ct_inventor_ipr", "ass_sim", "loc_sim"])
inputFile="/Users/aiyenggar/datafiles/patents/uspc.appl.master.csv"

forwardmapheader=["fc_year", "fc_region", "fc_total", "fc_sla", "fc_slap", "fc_slpa", "fc_slpap", "fc_sother", "fc_sl", "fc_sa"]
forwardmapFile="/Users/aiyenggar/datafiles/patents/forwardmap"
backwardmapheader=["bc_year", "bc_region", "bc_total", "bc_sla", "bc_slap", "bc_slpa", "bc_slpap", "bc_sother", "bc_sl", "bc_sa"]
backwardmapFile="/Users/aiyenggar/datafiles/patents/backwardmap"
mapFileIndex=0

k1 = open(inputFile, 'r', encoding='utf-8')
kreader1 = csv.reader(k1)

# Read the entire keysFile1 to memory
lDict=dict({})
forwardCitations=dict({})
backwardCitations=dict({})

for k1r in kreader1:
    if kreader1.line_num % 5000000 == 0:
        print("Read " + str(kreader1.line_num) + " patent citation-locations")

    if kreader1.line_num == 1:
        continue
    cg_patent_id = k1r[0]
    cg_inventor_year = k1r[1]
    cg_inventor_id = k1r[2]
    cg_inventor_region = k1r[3]
    cg_inventor_country = k1r[4]
    cg_inventor_ipr = k1r[5]
    ct_patent_id = k1r[6]
    ct_inventor_year = k1r[7]
    ct_inventor_id = k1r[8]
    ct_inventor_region = k1r[9]
    ct_inventor_country = k1r[10]
    ct_inventor_ipr = k1r[11]
    ass_sim = int(k1r[12])
    loc_sim = int(k1r[13])

    mkey = []
    mkey.append(ct_patent_id)
    mkey.append(cg_patent_id)
    mkey.append(ct_inventor_region)
    mkey.append(cg_inventor_region)
    mkey.append(ass_sim)
    tkey = tuple(mkey)
    # Look at one region-region only once per patent-patent citation
    if tkey not in lDict:
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
            
    if kreader1.line_num % 20000000 == 0:
        dump(getname(forwardmapFile, mapFileIndex, ".csv"), forwardCitations, forwardmapheader)
        forwardCitations = dict({})
        dump(getname(backwardmapFile, mapFileIndex, ".csv"), backwardCitations, backwardmapheader)
        backwardCitations = dict({})
        mapFileIndex = mapFileIndex + 1

dump(getname(forwardmapFile, mapFileIndex, ".csv"), forwardCitations, forwardmapheader)
dump(getname(backwardmapFile, mapFileIndex, ".csv"), backwardCitations, backwardmapheader)
print("Completed reading")
lDict = None
forwardCitations = None
backwardCitations = None
kreader1 = None
k1.close()


