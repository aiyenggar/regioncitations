"""
Created on Thu Mar  21 19:08:51 2019

@author: aiyenggar
"""

import csv
import sys
import pandas as pd
import time
import citationutils as ut

# read keysFile1
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
inv_uaid_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','ualist'], dtype={'patent_id':str,'ualist':str}, index_col='patent_id').to_dict()
# "year", "patent_id", "total_citations_received", "self_citations_received", "nonself_citations_received"
searchf = open(ut.pathPrefix + ut.outputPrefix + "-patent-citation-received.csv", 'r', encoding='utf-8')
sreader = csv.reader(searchf)
last_time = 0
inventor_missing_dict = {}
mapf = open(ut.pathPrefix + ut.outputPrefix + "-uayear-citation-received.csv", 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(["year", "uaid", "patent_id", "total_citations_received", "self_citations_received", "nonself_citations_received"])
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")
for citation in sreader:
    if sreader.line_num == 1:
        continue # we skip the header line
    if sreader.line_num >= last_time + ut.update_freq_lines:
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed " + str(sreader.line_num) + " patent citations")
        last_time = sreader.line_num
    year = citation[0]
    patent_id = citation[1]
    try:
        p_loc = inv_uaid_dict['ualist'][patent_id].split(',')
    except AttributeError:
        inventor_missing_dict = ut.adderr(inventor_missing_dict, patent_id, ut.attributeErrorValue[0])
        p_loc = ut.attributeErrorValue
    except KeyError:
        inventor_missing_dict = ut.adderr(inventor_missing_dict, patent_id, ut.keyErrorValue[0])
        p_loc = ut.keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " urbanarea-citation -> " + str(sys.exc_info()[1]))
        p_loc = ut.defaultErrorValue

    p_loc = list(set(p_loc)) # for a given patent, we need to see an urbanarea only once
    for pind in range(len(p_loc)):
        patloc = int(p_loc[pind])
        if ut.isValidUrbanArea(patloc):
            mapwriter.writerow([year, patloc] + citation[1:])

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
searchf.close()
mapf.close()