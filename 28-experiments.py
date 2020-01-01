#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 13:36:30 2019

@author: aiyenggar
"""
import citationutils as ut
import pandas as pd
import time

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
df = pd.read_csv(ut.citationFlowsFile, \
                 usecols = ['year', 'uaid', 'patent_id', 'citation_id', 'q0', 'q1', 'q2', 'q3', 'q4', 'q5'], \
                     dtype={'year':int, 'uaid':int, 'patent_id':str, 'citation_id':str, 'q0':float, 'q1':float, 'q2':float, 'q3':float, 'q4':float, 'q5':float}, \
                         index_col=['year', 'uaid'])
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Pre-processing")
df.to_parquet(ut.citationFlowsParquet, compression='gzip')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Writing to Parquet")

"""
year1980 = df[df['year'] == 1980]
retval1980 = year1980.to_csv('1980.csv')

#Pull entries by originating patent
onepat = df[df['patent_id'] == "7364810"]
onepat7364810 = onepat.to_csv('7364810.csv')

#Keep only one entry per uaid patent_id citation_id
onceuaid = df.drop_duplicates(subset=['uaid', 'patent_id', 'citation_id'], keep='first')
onceuaidretval = onceuaid.to_csv(ut.singleUaidFlowsFile)
"""
