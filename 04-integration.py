# -*- coding: utf-8 -*-
"""
Created on Sat Jan  7 05:48:51 2017

@author: aiyenggar
"""

import csv

pheader=list(["region","year","patent_count","pool_patent_count"])
patentsFile="/Users/aiyenggar/datafiles/patents/regionyear.csv"

forwardmapheader=["fc_year", "fc_region", "fc_total", "fc_sla", "fc_slap", "fc_slpa", "fc_slpap", "fc_sother", "fc_sl", "fc_sa"]
fmapFile="/Users/aiyenggar/datafiles/patents/forwardmap.csv"

backwardmapheader=["bc_year", "bc_region", "bc_total", "bc_sla", "bc_slap", "bc_slpa", "bc_slpap", "bc_sother", "bc_sl", "bc_sa"]
bmapFile="/Users/aiyenggar/datafiles/patents/backwardmap.csv"

outputheader=["year", "region", "patents", "pool", "cit_made_total", "cit_made_localinternal", "cit_made_localexternal", "cit_made_nonlocalinternal", "cit_made_nonlocalexternal", "cit_made_other", "cit_made_local", "cit_made_internal", "cit_recd_total", "cit_recd_local", "cit_recd_nonlocal", "cit_recd_other"]
outputFile="/Users/aiyenggar/datafiles/patents/citations.region.year.csv"

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
        pDict[pkey] = [patentsl[2], patentsl[3]]
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
        fDict[fkey] = [int(forwardl[2]), int(forwardl[3]), int(forwardl[4]), int(forwardl[5]), int(forwardl[6]), int(forwardl[7]), int(forwardl[8]), int(forwardl[9])]
    else:
        # multiple entries due to the division in 03-regioncitations.py
        prev = fDict[fkey]
        total = prev[0] + int(forwardl[2])
        sla = prev[1] + int(forwardl[3])
        slap = prev[2] + int(forwardl[4])
        slpa = prev[3] + int(forwardl[5])
        slpap = prev[4] + int(forwardl[6])
        sother = prev[5] + int(forwardl[7])
        sl = prev[6] + int(forwardl[8])
        sa = prev[7] + int(forwardl[9])
        fDict[fkey] = [total, sla, slap, slpa, slpap, sother, sl, sa]
        


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
        bDict[bkey] = [int(backwardl[2]), int(backwardl[3]), int(backwardl[4]), int(backwardl[5]), int(backwardl[6]), int(backwardl[7]), int(backwardl[8]), int(backwardl[9])]
    else:
        # multiple entries due to the division in 03-regioncitations.py
        prev = bDict[bkey]
        total = prev[0] + int(backwardl[2])
        sla = prev[1] + int(backwardl[3])
        slap = prev[2] + int(backwardl[4])
        slpa = prev[3] + int(backwardl[5])
        slpap = prev[4] + int(backwardl[6])
        sother = prev[5] + int(backwardl[7])
        sl = prev[6] + int(backwardl[8])
        sa = prev[7] + int(backwardl[9])
        bDict[bkey] = [total, sla, slap, slpa, slpap, sother, sl, sa]

outputf = open(outputFile, 'w', encoding='utf-8')
writer = csv.writer(outputf)
writer.writerow(outputheader)

for p in pDict:
    year = p[0]
    region = p[1]
    
    pv = pDict[p]
    patents = pv[0]
    pool = pv[1]
    
    if p in bDict:
        bv = bDict[p]
    else:
        bv = [0, 0, 0, 0, 0, 0, 0, 0]
    cit_made_total = bv[0]
    cit_made_localinternal = bv[1]
    cit_made_localexternal = bv[2]
    cit_made_nonlocalinternal = bv[3]
    cit_made_nonlocalexternal = bv[4]
    cit_made_other = bv[5]
    cit_made_local = bv[6]
    cit_made_internal = bv[7]
    
    if p in fDict:
        fv = fDict[p]
    else:
        fv = [0, 0, 0, 0, 0, 0, 0, 0]

    cit_recd_total = fv[0]
    cit_recd_local = fv[6]
    cit_recd_nonlocal = int(fv[3]) + int(fv[4])
    cit_recd_other = fv[5]
    writer.writerow([year, region, patents, pool, cit_made_total, cit_made_localinternal, cit_made_localexternal, cit_made_nonlocalinternal, cit_made_nonlocalexternal, cit_made_other, cit_made_local, cit_made_internal, cit_recd_total, cit_recd_local, cit_recd_nonlocal, cit_recd_other])

outputf.close()