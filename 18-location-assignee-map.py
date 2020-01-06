#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan  6 22:07:15 2020

@author: aiyenggar
"""

import csv
import time
import citationutils as ut

p_set = set([])
i_dict = {}
l_dict = {}
u_dict = {}
a_dict = {}

# Assume no duplicates and read them all into dictionaries
# patent_id,inventor_id,latlongid,uaid
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading " + ut.patentUrbanAreaFile)
uaf = open(ut.patentUrbanAreaFile, 'r', encoding='utf-8')
uareader = csv.reader(uaf)
for ualine in uareader:
    if uareader.line_num == 1:
        continue # we skip the header line
    patent_id = ualine[0]
    if patent_id not in p_set:
        p_set.add(patent_id)

    inventor_id = ualine[1]
    if patent_id in i_dict:
        i_dict[patent_id] += [inventor_id]
    else:
        i_dict[patent_id] = [inventor_id]
    
    latlongid = ualine[2]
    if patent_id in l_dict:
        l_dict[patent_id] += [latlongid]
    else:
        l_dict[patent_id] = [latlongid]
    
    uaid = ualine[3]
    if patent_id in u_dict:
        u_dict[patent_id] += [uaid]
    else:
        u_dict[patent_id] = [uaid]    
uaf.close()

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading " + ut.patentAssigneeFile)
assgf = open(ut.patentAssigneeFile, 'r', encoding='utf-8')
assgreader = csv.reader(assgf)
for assgline in assgreader:
    if assgreader.line_num == 1:
        continue # we skip the header line
    patent_id = assgline[0]
    if patent_id not in p_set:
        p_set.add(patent_id)
    
    assg_numid = assgline[1]
    if patent_id in a_dict:
        a_dict[patent_id] += [assg_numid]
    else:
        a_dict[patent_id] = [assg_numid]
assgf.close()

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processing  " + ut.keysFile1)
mapf = open(ut.keysFile1, 'w', encoding='utf-8')
mapwriter = csv.writer(mapf)
mapwriter.writerow(["patent_id", "inventor_id_list", "latlongid_list", "uaid_list", "assignee_numid_list"])
#ut.keysFile1
for patent_id in sorted(p_set):
    if patent_id in i_dict:
        ilist = ",".join(map(str,i_dict[patent_id]))
    else:
        ilist = ""
    if patent_id in l_dict:
        llist = ",".join(map(str,l_dict[patent_id]))
    else:
        llist = ""
    if patent_id in u_dict:
        ulist = ",".join(map(str,u_dict[patent_id]))
    else:
        ulist = ""
    if patent_id in a_dict:
        alist = ",".join(map(str,a_dict[patent_id]))
    else:
        alist = ""
    mapwriter.writerow([patent_id, ilist, llist, ulist, alist])
mapf.close()
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Done  ")