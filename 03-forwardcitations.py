# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 05:48:51 2016

@author: aiyenggar
"""

import csv
#"cg_patent_id", "ct_patent_id", "cg_inventor_year",  "cg_inventor_id", "cg_inventor_region", "cg_inventor_country", "cg_inventor_ipr", "ct_inventor_id", "ct_inventor_region", "ct_inventor_country", "ct_inventor_ipr", "ass_sim", "loc_sim"
inputFile="/Users/aiyenggar/datafiles/patents/uspc.appl.master.csv"
oheader=["cg_patent_id", "ct_patent_id", "cg_inventor_year",  "cg_inventor_region", "cg_inventor_country", "cg_inventor_ipr", "ct_inventor_region", "ct_inventor_country", "ct_inventor_ipr", "ass_sim", "loc_sim", "la", "lap", "lpa", "lpap"]
outputFile="/Users/aiyenggar/datafiles/patents/26-summer.csv"

soheader=["cg_inventor_year",  "cg_inventor_region", "cg_inventor_country", "cg_inventor_ipr",  "yr_reg_total", "nla", "nlap", "nlpa", "nlpap", "nl", "na"]
secondOutputFile="/Users/aiyenggar/datafiles/patents/summer.csv"

k1 = open(inputFile, 'r', encoding='utf-8')
kreader1 = csv.reader(k1)
outputf = open(outputFile, 'w', encoding='utf-8')
writer = csv.writer(outputf)

# Read the entire keysFile1 to memory
lDict=dict({})
bDict=dict({})
for k1r in kreader1:
    if kreader1.line_num % 1000000 == 0:
        print("Read " + str(kreader1.line_num) + " patent citation-locations")
    if kreader1.line_num == 1:
        writer.writerow(oheader)
        continue
    cg_patent_id = k1r[0]
    ct_patent_id = k1r[1]
    cg_inventor_year = k1r[2]
    cg_inventor_id = k1r[3]
    cg_inventor_region = k1r[4]
    cg_inventor_country = k1r[5]
    cg_inventor_ipr = k1r[6]
    ct_inventor_id = k1r[7]
    ct_inventor_region = k1r[8]
    ct_inventor_country = k1r[9]
    ct_inventor_ipr = k1r[10]
    ass_sim = k1r[11]
    loc_sim = k1r[12]
    if (int(cg_inventor_year) < 2001):
        continue
    if (int(cg_inventor_year) > 2012):
        continue
    if (int(loc_sim) == 2):
        continue
    if (int(ass_sim) == 2):
        continue
    mkey = []
    mkey.append(cg_patent_id)
    mkey.append(ct_patent_id)
    mkey.append(cg_inventor_region)
    mkey.append(ct_inventor_region)
    tkey = tuple(mkey)
    if tkey in lDict:
        continue
    else:
        lDict[tkey] = 1
    if (loc_sim == "1" and ass_sim == "1"):
        la = 1
    else:
        la = 0
    if (loc_sim == "1" and ass_sim == "0"):
        lap = 1
    else:
        lap = 0
    if (loc_sim == "0" and ass_sim == "1"):
        lpa = 1
    else:
        lpa = 0
    if (loc_sim == "0" and ass_sim == "0"):
        lpap = 1
    else:
        lpap = 0
    
    nkey = []
    nkey.append(cg_inventor_year)
    nkey.append(cg_inventor_region)
    ntkey = tuple(nkey)
    if ntkey not in bDict:
        bDict[ntkey] = [1, 0, 0, 0, 0]
    else:
        prev = bDict[ntkey]
        total = prev[0] + 1
        sla = prev[1] + la
        slap = prev[2] + lap
        slpa = prev[3] + lpa
        slpap = prev[4] + lpap
        bDict[ntkey] = [total, sla, slap, slpa, slpap]
    out = list([cg_patent_id, ct_patent_id, cg_inventor_year, cg_inventor_region, cg_inventor_country, cg_inventor_ipr, ct_inventor_region, ct_inventor_country, ct_inventor_ipr, ass_sim, loc_sim, la, lap, lpa, lpap])
    writer.writerow(out)

kreader1 = None
k1.close()
outputf.close()

#potentially write out nkey+bDict[ntkey] so that you dont have to run the above to run the below
outputf = open(outputFile, 'r', encoding='utf-8')
reader = csv.reader(outputf)

secondf = open(secondOutputFile, 'w', encoding='utf-8')
writer = csv.writer(secondf)

seen=dict({})
for row in reader:
    if reader.line_num % 1000000 == 0:
        print("Read " + str(reader.line_num) + " patent citation-locations")
    if reader.line_num == 1:
        writer.writerow(soheader)
        continue
    nkey = []
    nkey.append(row[2])
    nkey.append(row[3])
    ntkey = tuple(nkey)
    if ntkey not in bDict:
        print("Missing tuple" + str(ntkey) + " in my data")
    else:
        if ntkey in seen:
            continue
        seen[ntkey] = 1
        prev = bDict[ntkey]
        total = prev[0]
        sla = prev[1]
        slap = prev[2]
        slpa = prev[3]
        slpap = prev[4]
        nla = (sla*100)/total
        nlap = (slap*100)/total
        nlpa = (slpa*100)/total
        nlpap = (slpap*100)/total
        nl = nla + nlap
        na = nla + nlpa
        writer.writerow([row[2], row[3], row[4], row[5], total, nla, nlap, nlpa, nlpap, nl, na])
        
outputf.close()
secondf.close()