# -*- coding: utf-8 -*-
"""
Created on Sat Jan  7 05:48:51 2017

@author: aiyenggar
"""

import csv

pheader=list(["region","year","patent_count","pool_patent_count","cat1","cat2","cat3","cat4","cat5","cat6","cat7","subcat11","subcat12","subcat13","subcat14","subcat15","subcat19","subcat21","subcat22","subcat23","subcat24","subcat25","subcat31","subcat32","subcat33","subcat39","subcat41","subcat42","subcat43","subcat44","subcat45","subcat46","subcat49","subcat51","subcat52","subcat53","subcat54","subcat55","subcat59","subcat61","subcat62","subcat63","subcat64","subcat65","subcat66","subcat67","subcat68","subcat69","subcat70","dcat1","dcat2","dcat3","dcat4","dcat5","dcat6","dcat7","dsubcat11","dsubcat12","dsubcat13","dsubcat14","dsubcat15","dsubcat19","dsubcat21","dsubcat22","dsubcat23","dsubcat24","dsubcat25","dsubcat31","dsubcat32","dsubcat33","dsubcat39","dsubcat41","dsubcat42","dsubcat43","dsubcat44","dsubcat45","dsubcat46","dsubcat49","dsubcat51","dsubcat52","dsubcat53","dsubcat54","dsubcat55","dsubcat59","dsubcat61","dsubcat62","dsubcat63","dsubcat64","dsubcat65","dsubcat66","dsubcat67","dsubcat68","dsubcat69","dsubcat70"])
patentsFile="/Users/aiyenggar/datafiles/patents/urbanareas.year.csv"

forwardmapheader=["fc_year", "fc_region", "fc_total", "fc_sla", "fc_slap", "fc_slpa", "fc_slpap", "fc_sother", "fc_sl", "fc_sa"]
fmapFile1="/Users/aiyenggar/datafiles/patents/ae.forwardmap.csv"
fmapFile2="/Users/aiyenggar/datafiles/patents/e.forwardmap.csv"
fmapFile3="/Users/aiyenggar/datafiles/patents/a.forwardmap.csv"

backwardmapheader=["bc_year", "bc_region", "bc_total", "bc_sla", "bc_slap", "bc_slpa", "bc_slpap", "bc_sother", "bc_sl", "bc_sa"]
bmapFile1="/Users/aiyenggar/datafiles/patents/ae.backwardmap.csv"
bmapFile2="/Users/aiyenggar/datafiles/patents/e.backwardmap.csv"
bmapFile3="/Users/aiyenggar/datafiles/patents/a.backwardmap.csv"

outputheader=["year", "region", "patents", "pool", "cit_made_total", "cit_made_localinternal", "cit_made_localexternal", "cit_made_nonlocalinternal", "cit_made_nonlocalexternal", "cit_made_other", "cit_made_local", "cit_made_internal", "cit_recd_total", "cit_recd_local", "cit_recd_nonlocal", "cit_recd_self", "cit_recd_nonself", "cit_recd_other"]
outputFile1="/Users/aiyenggar/datafiles/patents/ae.citations.urbanareas.year.csv"
outputFile2="/Users/aiyenggar/datafiles/patents/e.citations.urbanareas.year.csv"
outputFile3="/Users/aiyenggar/datafiles/patents/a.citations.urbanareas.year.csv"

fmapFile=fmapFile1
bmapFile=bmapFile1
outputFile=outputFile1

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
        fDict[fkey] = [int(forwardl[2]), int(forwardl[3]), int(forwardl[4]), int(forwardl[5]), int(forwardl[6]), 
int(forwardl[7]), int(forwardl[8]), int(forwardl[9])]
    else:
        # multiple entries due to the division in 03-urbanareas_citations.py
        prev = fDict[fkey]
        total = prev[0] + int(forwardl[2])
        sla = prev[1] + int(forwardl[3])
        slap = prev[2] + int(forwardl[4])
        slpa = prev[3] + int(forwardl[5])
        slpap = prev[4] + int(forwardl[7])
        sother = prev[5] + int(forwardl[7])
        sl = prev[6] + int(forwardl[8])
        sa = prev[7] + int(forwardl[9])
        fDict[fkey] = [total, sla, slap, slpa, slpap, sother, sl, sa]
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
    cit_recd_self = int(fv[1]) + int(fv[3])
    cit_recd_nonself = int(fv[2]) + int(fv[4])
    cit_recd_other = fv[5]
    baserow = [year, region, patents, pool, cit_made_total, cit_made_localinternal, cit_made_localexternal, cit_made_nonlocalinternal, cit_made_nonlocalexternal, cit_made_other, cit_made_local, cit_made_internal, cit_recd_total, cit_recd_local, cit_recd_nonlocal, cit_recd_self, cit_recd_nonself, cit_recd_other]
    writer.writerow(baserow+dummies)

outputf.close()