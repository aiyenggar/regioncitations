"""
Created on Thu Mar  21 19:08:51 2019

@author: aiyenggar
"""

import csv
import time
import citationutils as ut
import pandas as pd

citcnt_dict = pd.read_csv(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-count.csv", usecols = ['patent_id','expanded_citations'], dtype={'patent_id':str,'expanded_citations':int}, index_col='patent_id').to_dict()

allflows="ALL"
uniqueflows="UNIQ"
mapf = open(ut.pathPrefix + ut.outputPrefix + "-predictor-variables.csv", 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(["year", "uaid", "citation_type", "countstyle", "cit_made_total", "q1", "q2", "q3", "q4", "q5"])
prior_lines = 0
pv_dict = {}
patentseen = ""
# "year", "m_patent_id", "m_inventor_uaid", "m_assignee_id", "r_patent_id", "r_inventor_uaid", "r_assignee_id", "citation_type"
for index in range(1, ut.expandedCitationLastFileSuffix+1):
    searchf = open(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-made-" + str(index) + ".csv", 'r', encoding='utf-8')
    sreader = csv.reader(searchf)
    last_time = 0

    for citation in sreader:
        if sreader.line_num == 1:
            continue # we skip the header line
        if sreader.line_num >= last_time + ut.update_freq_lines:
            print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(prior_lines + sreader.line_num) + " expanded citations")
            last_time = sreader.line_num
        # the following assumes that citations from a patent all appear together and then never again
        # the following is done to prevent seen_dict from getting very large
        if patentseen != citation[1]:
            seen_dict = {}
            patentseen = citation[1]
        # key counting_method, citation_type, year, uaid
        # value q1-q5
        # Within Cluster, Within Firm: q1
        # Within Cluster, Outside Frim: q2
        # Outside Cluster, Outside Firm: q3
        # Outside Cluster, Within Firm: q4
        # Not determinable: q5
        if not ut.isValidUrbanArea(citation[2]):
            continue

        if (not ut.isValidAssignee(citation[3])) and (not ut.isValidAssignee(citation[6])):
            quadrant = 5
        else:
            if citation[2] == citation[5]: # same cluster
                if citation[3] == citation[6]: # same firm
                    quadrant = 1
                else: # different firm
                    quadrant = 2
            else: # different cluster
                if citation[3] == citation[6]: # same firm
                    quadrant = 4
                else: # different firm
                    quadrant = 3
        for ctype in [100, int(citation[7])]:
            key1 = tuple([citation[0], citation[2], ctype, allflows])
            if key1 not in pv_dict:
                pv_dict[key1] = [0, 0, 0, 0, 0, 0]
            expanded_citations = citcnt_dict['expanded_citations'][citation[1]]
            if expanded_citations != 0:
                pv_dict[key1][quadrant] += 1/expanded_citations
            else:
                print(citation[1] + " has zero expanded citations")

        skey = tuple(citation)
        if skey not in seen_dict:
            for ctype in [100, int(citation[7])]:
                key2 = tuple([citation[0], citation[2], ctype, uniqueflows])
                if key2 not in pv_dict:
                    pv_dict[key2] = [0, 0, 0, 0, 0, 0]
                expanded_citations = citcnt_dict['expanded_citations'][citation[1]]
                if expanded_citations != 0:
                    pv_dict[key2][quadrant] += 1/expanded_citations
                else:
                    print(citation[1] + " has zero expanded citations")
            seen_dict[skey] = 1

    prior_lines += sreader.line_num
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(prior_lines) + " expanded citations (End of File)")
    searchf.close()

for key in pv_dict:
    pv_dict[key][0] = round(pv_dict[key][1] + pv_dict[key][2] + pv_dict[key][3] + pv_dict[key][4] + pv_dict[key][5], 4)
    pv_dict[key][1] = round(pv_dict[key][1], 4)
    pv_dict[key][2] = round(pv_dict[key][2], 4) 
    pv_dict[key][3] = round(pv_dict[key][3], 4)
    pv_dict[key][4] = round(pv_dict[key][4], 4)
    pv_dict[key][5] = round(pv_dict[key][5], 4)
    mapwriter.writerow(list(key) + pv_dict[key])
mapf.close()