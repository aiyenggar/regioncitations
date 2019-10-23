#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 23 19:05:08 2019

@author: aiyenggar
"""
import csv
import citationutils as ut
from itertools import combinations

searchf = open(ut.pathPrefix+"patent_cpc_nid_subgroup.csv", 'r', encoding='utf-8')
sreader = csv.reader(searchf)
dict = {}
subgroups = []
current_patent = None
for line in sreader:
    if sreader.line_num == 1:
        continue
    f0 = line[0]
    f1 = int(line[1])
    if f0 == current_patent:
        subgroups.append(f1)
    else:
        if (current_patent != None):
            # process the prior list
            subgroups =list(sorted(set(subgroups)))
            comb = combinations(subgroups, 2)
            for c in comb:
                if c not in dict:
                    dict[c] = current_patent
        current_patent = f0
        subgroups = [f1]
subgroups =list(sorted(set(subgroups)))
comb = combinations(subgroups, 2)
for c in comb:
    if c not in dict:
        dict[c] = current_patent
current_patent = None
subgroups = list()

with open(ut.pathPrefix+"novel-cpc.csv", 'w') as csvFile:
    writer = csv.writer(csvFile)
    writer.writerow(['nid_subgroup1', 'nid_subgroup2', 'initial_patent'])
    for nextkey in dict.keys():
        writer.writerow([nextkey[0], nextkey[1], dict[nextkey]])
    csvFile.close()