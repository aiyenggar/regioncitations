"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import pandas as pd
import time
import citationutils as ut

# read keysFile1
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
assignee_dict = pd.read_csv(ut.inputfile22, usecols = ['patent_id','assigneelist'], dtype={'patent_id':str,'assigneelist':str}, index_col='patent_id').to_dict()
citrecd = {}
searchf = open(ut.searchfile22, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")
for citation in sreader:
    if sreader.line_num == 1:
        continue # we skip the header line
    if sreader.line_num >= last_time + ut.update_freq_lines:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num) + " raw citations")
        last_time = sreader.line_num
    try:
        year = int(citation[0])
    except ValueError:
        continue
    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    if (len(citation_id) == 0):
        continue
    type_citation = int(citation[3]) # 1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party
    seq_citation = int(citation[4])
    kind_citation = citation[5] # B1, A etc

    p_ass = ut.splitFromDict(patent_id, "assigneelist", ",", assignee_dict)
    c_ass = ut.splitFromDict(citation_id, "assigneelist", ",", assignee_dict)

    key = tuple([year, citation_id])
    if key not in citrecd:
        citrecd[key] = [0, 0, 0]
    citrecd[key][0] += 1 # increment total citations received
    selfcount = 0
    nonselfcount = 0
    for apind in range(len(p_ass)):
        for acind in range(len(c_ass)):
            patass = int(p_ass[apind])
            citass = int(c_ass[acind])
            if patass == citass:
                selfcount += 1
            else:
                nonselfcount += 1
    if selfcount > 0:
        citrecd[key][1] += 1 # increment self citations received
    if nonselfcount > 0:
        citrecd[key][2] += 1 # increment nonself citations received

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
mapf = open(ut.outputfile22, 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(ut.outputheader22)
for key in citrecd:
    mapwriter.writerow(list(key) + citrecd[key])
mapf.close()

errf = open(ut.errorfile22, 'w', encoding='utf-8')
errwriter = csv.writer(errf)
errwriter.writerow(ut.errorheader22)
for key in ut.missing_dict:
    errwriter.writerow(list(key) + [ut.missing_dict[key]])
ut.missing_dict = {}
errf.close()