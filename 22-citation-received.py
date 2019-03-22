"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import sys
import pandas as pd
import time
import citationutils as ut

# read keysFile1
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
assignee_dict = pd.read_csv(ut.keysFile1, usecols = ['patent_id','assigneelist'], dtype={'patent_id':str,'assigneelist':str}, index_col='patent_id').to_dict()
inventor_missing_dict = {}
assignee_missing_dict = {}
total_citrecd = {}
self_citrecd = {}
nonself_citrecd = {}
searchf = open(ut.searchFileName, 'r', encoding='utf-8')
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

    try:
        p_ass = assignee_dict['assigneelist'][patent_id].split(',')
    except AttributeError:
        # we assume the value would have returned nan, implying a missing assignee field
        assignee_missing_dict = ut.adderr(assignee_missing_dict, patent_id, ut.attributeErrorValue[0])
        p_ass = ut.attributeErrorValue
    except KeyError:
        assignee_missing_dict = ut.adderr(assignee_missing_dict, patent_id, ut.keyErrorValue[0])
        p_ass = ut.keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " PASS -> " + patent_id + " " + str(sys.exc_info()[1]))
        p_ass = ut.defaultErrorValue

    try:
        c_ass = assignee_dict['assigneelist'][citation_id].split(',')
    except AttributeError:
        # we assume the value would have returned nan, implying a missing assignee field
        assignee_missing_dict = ut.adderr(assignee_missing_dict, citation_id, ut.attributeErrorValue[0])
        c_ass = ut.attributeErrorValue
    except KeyError:
        assignee_missing_dict = ut.adderr(assignee_missing_dict, citation_id, ut.keyErrorValue[0])
        c_ass = ut.keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " CASS -> " + citation_id + " >> " + str(sys.exc_info()[1]))
        c_ass = ut.defaultErrorValue

    key = tuple([year, citation_id])
    total_citrecd = ut.incrdict(key, total_citrecd)
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
        self_citrecd = ut.incrdict(key, self_citrecd)
    if nonselfcount > 0:
        nonself_citrecd = ut.incrdict(key, nonself_citrecd)

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed reading through search file")
mapf = open(ut.pathPrefix + ut.outputPrefix + "-patent-citation-received.csv", 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(["year", "patent_id", "total_citations_received", "self_citations_received", "nonself_citations_received"])
for key in total_citrecd:
    totalcnt = total_citrecd[key]
    if key in self_citrecd:
        selfcnt = self_citrecd[key]
    else:
        selfcnt = 0
    if key in nonself_citrecd:
        nonselfcnt = nonself_citrecd[key]
    else:
        nonselfcnt = 0
    mapwriter.writerow(list(key) + [totalcnt, selfcnt, nonselfcnt])
mapf.close()