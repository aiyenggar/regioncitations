#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 11 18:02:19 2019

@author: aiyenggar
"""

import csv
import time
import citationutils as ut

#cntf = open(ut.pathPrefix + ut.outputPrefix + "-ecc.csv", 'w', encoding='utf-8')
cntf = open(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-count.csv", 'w', encoding='utf-8')

cntwriter = csv.writer(cntf)
cntwriter.writerow(["patent_id", "citation_type", "expanded_citations"])
citcntdict = {}
prior_lines = 0
patentseen = ""
# "year", "m_patent_id", "m_inventor_uaid", "m_assignee_id", "r_patent_id", "r_inventor_uaid", "r_assignee_id", "citation_type"
for index in range(1, ut.expandedCitationLastFileSuffix+1):
#    searchf = open(ut.pathPrefix + ut.outputPrefix + "-ecm-" + str(index) + ".csv", 'r', encoding='utf-8')
    searchf = open(ut.pathPrefix + ut.outputPrefix + "-expanded-citation-made-" + str(index) + ".csv", 'r', encoding='utf-8')
    sreader = csv.reader(searchf)
    last_time = 0

    for citation in sreader:
        if sreader.line_num == 1:
            continue # we skip the header line
        # the following assumes that citations from a patent all appear together and then never again
        if patentseen != citation[1]:
            if sreader.line_num >= last_time + ut.update_freq_lines:
                for key in citcntdict:
                    patent_id = key[0]
                    citation_type = int(key[1])
                    count = citcntdict[key]
                    cntwriter.writerow([patent_id, citation_type, count])                
                cntf.flush()
                citcntdict = {}
                all_citations = 0
                print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(prior_lines + sreader.line_num) + " expanded citations")
                last_time = sreader.line_num
            patentseen = citation[1]
        ckey = tuple([citation[1], int(citation[7])])
        if ckey not in citcntdict:
            citcntdict[ckey] = 0
        citcntdict[ckey] += 1
    prior_lines += sreader.line_num
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(prior_lines) + " expanded citations (End of File)")
    searchf.close()

for key in citcntdict:
    patent_id = key[0]
    citation_type = int(key[1])
    count = citcntdict[key]
    all_citations += count
    cntwriter.writerow([patent_id, citation_type, count])                
cntf.close()
