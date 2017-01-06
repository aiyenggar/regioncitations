# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 05:48:51 2016

@author: aiyenggar
"""

import csv

# 0-patent_id,1-inventor_id,2-region,3-region_source,4-country,5-year
keysFile1="/Users/aiyenggar/datafiles/patents/rawinventor_region.csv"

#0-patent_id,1-assignee_id,2-region,3-region_source,4-country
keysFile2="/Users/aiyenggar/datafiles/patents/rawassignee_region.csv"

#0-country,1-ipr_score
keysFile3="/Users/aiyenggar/datafiles/patents/country_ipr.csv"

#0-uuid,1-patent_id,2-citation_id,3-date,4-name,5-kind,6-country,7-category,8-sequence
searchFile="/Users/aiyenggar/datafiles/patents/uspatentcitation.applicant.csv"


masster_kheader=list(["cit_uuid", "cg_patent_id", "ct_patent_id", "cg_inventor_year", "cg_assignee_id", "cg_assignee_region", "cg_assignee_region_source", "cg_assignee_country", "cg_assignee_ipr", "ct_assignee_id", "ct_assignee_region", "ct_assignee_region_source", "ct_assignee_country", "ct_assignee_ipr", "cg_inventor_id", "cg_inventor_region", "cg_inventor_region_source", "cg_inventor_country", "cg_inventor_ipr", "ct_inventor_id", "ct_inventor_region", "ct_inventor_region_source", "ct_inventor_country", "ct_inventor_ipr", "ass_sim", "loc_sim"])
kheader=list(["cg_patent_id", "ct_patent_id", "cg_inventor_year",  "cg_inventor_id", "cg_inventor_region", "cg_inventor_country", "cg_inventor_ipr", "ct_inventor_id", "ct_inventor_region", "ct_inventor_country", "ct_inventor_ipr", "ass_sim", "loc_sim"])
outputFile="/Users/aiyenggar/datafiles/patents/uspc.appl.master.csv"

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

k1 = open(keysFile1, 'r', encoding='utf-8')
kreader1 = csv.reader(k1)

# Read the entire keysFile1 to memory
iDict=dict({})
for k1r in kreader1:
    if kreader1.line_num == 1:
        continue
    if (k1r[0] not in iDict):
        iDict[k1r[0]] = list([])
    iDict[k1r[0]].append([k1r[1],k1r[2],k1r[3],k1r[4],k1r[5]])
    if kreader1.line_num % 1000000 == 0:
        print("Read " + str(kreader1.line_num) + " patent inventor locations")
print("done reading rawinventor_region.csv to memory")
kreader1 = None
k1.close()

k2 = open(keysFile2, 'r', encoding='utf-8')
kreader2 = csv.reader(k2)

# Read the entire keysFile1 to memory
aDict=dict({})
for k2r in kreader2:
    if kreader2.line_num == 1:
        continue
    if (k2r[0] not in aDict):
        aDict[k2r[0]] = list([])
    aDict[k2r[0]].append([k2r[1],k2r[2],k2r[3],k2r[4]])
    if kreader2.line_num % 1000000 == 0:
        print("Read " + str(kreader2.line_num) + " assignee locations")
print("done reading rawassignee_region.csv to memory")
kreader2 = None
k2.close()

k3 = open(keysFile3, 'r', encoding='utf-8')
kreader3 = csv.reader(k3)

# Read the entire keysFile1 to memory
cDict=dict({})
for k3r in kreader3:
    if kreader3.line_num == 1:
        continue
    if (k3r[0] not in cDict):
        cDict[k3r[0]] = k3r[1]
    else:
        print("Repeating country " + k3r[0] + " in country_ipr.csv, Skipping")
print("done reading country_ipr.csv to memory")
kreader3 = None
k3.close()

searchf = open(searchFile, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
outputf = open(outputFile, 'w', encoding='utf-8')
writer = csv.writer(outputf)

for entry in sreader:
   if sreader.line_num == 1:
       writer.writerow(kheader)
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
           icg_list = ll5
   else:
       icg_list = ll5
       #print("Citing " + cg_patent_id + " not found in the iDict dictionary")
           
   for next_entry in icg_list:
       cg_inventor_id = next_entry[0]
       cg_inventor_region = next_entry[1]
       cg_inventor_region_source = next_entry[2]
       cg_inventor_country = next_entry[3]
       cg_inventor_year = next_entry[4]
       acg_list = None
       #Loop 2
       if (cg_patent_id in aDict):
           acg_list = aDict[cg_patent_id]
           if (len(acg_list) == 0):
               #print("Citing " + cg_patent_id + " of length 0 in aDict dictionary")
               acg_list = ll4
       else:
           acg_list = ll4 
           #print("Citing " + cg_patent_id + " not found in aDict dictionary")
           
       for ext_entry in acg_list:
           cg_assignee_id = ext_entry[0]
           cg_assignee_region = ext_entry[1]
           cg_assignee_region_source = ext_entry[2]
           cg_assignee_country = ext_entry[3]
           ict_list = None   
           #Loop 3
           if (ct_patent_id in iDict): 
               ict_list = iDict[ct_patent_id] 
               if (len(ict_list) == 0):
                   #print("Cited " + ct_patent_id + " of length 0 in iDict dictionary")
                   ict_list = ll5
           else:
               ict_list = ll5
               #print("Cited " + ct_patent_id + " not found in the iDict dictionary")
               
           for xt_entry in ict_list:
               ct_inventor_id = xt_entry[0]
               ct_inventor_region = xt_entry[1]
               ct_inventor_region_source = xt_entry[2]
               ct_inventor_country = xt_entry[3]
               ct_inventor_year = xt_entry[4]
               act_list = None
               #Loop 4
               if (ct_patent_id in aDict):
                   act_list = aDict[ct_patent_id]
                   if (len(act_list) == 0):
                       #print("Cited " + ct_patent_id + " of length 0 in aDict dictionary")
                       act_list = ll4
               else:
                   act_list = ll4 
                   #print("Cited " + ct_patent_id + " not found in aDict dictionary")
               for t_entry in act_list:
                   ct_assignee_id = t_entry[0]
                   ct_assignee_region = t_entry[1]
                   ct_assignee_region_source = t_entry[2]
                   ct_assignee_country = t_entry[3]
                   
                   # We are now ready to write a line
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
                   #master_out = list([cit_uuid, cg_patent_id, ct_patent_id, cg_inventor_year, cg_assignee_id, cg_assignee_region, cg_assignee_region_source, cg_assignee_country, cg_assignee_ipr, ct_assignee_id, ct_assignee_region, ct_assignee_region_source, ct_assignee_country, ct_assignee_ipr, cg_inventor_id, cg_inventor_region, cg_inventor_region_source, cg_inventor_country, cg_inventor_ipr, ct_inventor_id, ct_inventor_region, ct_inventor_region_source, ct_inventor_country, ct_inventor_ipr, ass_sim, loc_sim])
                   out = list([cg_patent_id, ct_patent_id, cg_inventor_year, cg_inventor_id, cg_inventor_region, cg_inventor_country, cg_inventor_ipr, ct_inventor_id, ct_inventor_region, ct_inventor_country, ct_inventor_ipr, ass_sim, loc_sim])
                   writer.writerow(out)
   if sreader.line_num % 1000000 == 0:
        print("Processed " + str(sreader.line_num) + " lines")

outputf.close()
searchf.close()
