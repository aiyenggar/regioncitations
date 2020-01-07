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
inv_uaid_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','uaid_list'], dtype={'patent_id':str,'uaid_list':str}, index_col='patent_id').to_dict()
assignee_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','assignee_numid_list'], dtype={'patent_id':str,'assignee_numid_list':str}, index_col='patent_id').to_dict()
searchf = open(ut.searchFileName, 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
mapf = open(ut.outputfile22, 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(ut.outputheader22)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")
for citation in sreader:
    citrecd = {}
    if sreader.line_num == 1:
        continue # we skip the header line
    if sreader.line_num >= last_time + ut.update_freq_lines:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num) + " raw citations")
        last_time = sreader.line_num
        mapf.flush()
    try:
        year = int(citation[0])
    except ValueError:
        continue
    patent_id = citation[1].strip() # to remove leading and trailing spaces
    citation_id = citation[2].strip() # to remove leading and trailing spaces
    if (len(citation_id) == 0):
        continue
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

        
    p_ass = ut.splitFromDict(patent_id, "assignee_numid_list", ",", assignee_dict)
    c_ass = ut.splitFromDict(citation_id, "assignee_numid_list", ",", assignee_dict)
    c_loc = ut.splitFromDict(citation_id, "uaid_list", ",", inv_uaid_dict)
    c_count_inventors = len(c_loc)
    
    wt_all_citations = 1
    if c_count_inventors > 1:
        wt_all_citations *= c_count_inventors

    p_ass_cnt = len(p_ass)
    c_ass_cnt = len(c_ass)
    wt_self_citations = wt_all_citations
    if p_ass_cnt > 1:
        wt_self_citations *= p_ass_cnt
    if c_ass_cnt > 1:
        wt_self_citations *= c_ass_cnt
        
    for cind in range(len(c_loc)):
        citloc = int(c_loc[cind])
        key = tuple([citation_id, patent_id, citloc])
        if key not in citrecd:
            citrecd[key] = [0.0, 0.0, 0.0]
        citrecd[key][0] += (1/wt_all_citations) # increment total citations received

        for apind in range(p_ass_cnt):
            for acind in range(c_ass_cnt):
                patass = int(p_ass[apind])
                citass = int(c_ass[acind])

                if patass == citass:
                    citrecd[key][1] += (1/wt_self_citations)
                else:
                    citrecd[key][2] += (1/wt_self_citations) # Weighting for non-self citations is the same as that for self-citations
    for key in citrecd:
        mapwriter.writerow(list(key) + [round(x,8) for x in citrecd[key]]  + [year])


print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
mapf.close()

errf = open(ut.errorfile22, 'w', encoding='utf-8')
errwriter = csv.writer(errf)
errwriter.writerow(ut.errorheader22)
for key in ut.missing_dict:
    errwriter.writerow(list(key) + [ut.missing_dict[key]])
ut.missing_dict = {}
errf.close()