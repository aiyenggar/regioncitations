"""
Created on Thu Mar  21 19:08:51 2019

@author: aiyenggar
"""

import csv
import time
import citationutils as ut

# "year", "uaid", "patent_id", "total_citations_received", "self_citations_received", "nonself_citations_received"
searchf = open(ut.pathPrefix + ut.outputPrefix + "-uayear-citation-received.csv", 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
dvdict = {}
mapf = open(ut.pathPrefix + ut.outputPrefix + "-dependent-variable.csv", 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(["year", "uaid", "cit_recd_total", "cit_recd_self", "cit_recd_nonself"])
for citation in sreader:
    if sreader.line_num == 1:
        continue # we skip the header line
    if sreader.line_num >= last_time + ut.update_freq_lines:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num) + " urbanarea year citations received")
        last_time = sreader.line_num
    key = tuple([citation[0], citation[1]])
    if (key in dvdict):
        t = int(citation[3]) + dvdict[key][0]
        s = int(citation[4]) + dvdict[key][1]
        n = int(citation[5]) + dvdict[key][2]
        dvdict[key] = [t, s, n]
    else:
        dvdict[key] = [int(citation[3]), int(citation[4]), int(citation[5])]

for key in dvdict:
    mapwriter.writerow(list(key) + dvdict[key])
searchf.close()
mapf.close()