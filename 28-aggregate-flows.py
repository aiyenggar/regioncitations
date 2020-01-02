#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 13:36:30 2019

@author: aiyenggar
"""
import citationutils as ut
import pandas as pd
import time

maxindex = 10
last_index = 0
bigdf = None
while last_index < maxindex:
    last_index += 1
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting " + ut.singleUaidFlowsFile % last_index)
    df = pd.read_parquet(ut.singleUaidFlowsFile % last_index)
    if bigdf == None:
        bigdf = df
    else:
        bigdf.append(df)
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed " + ut.singleUaidFlowsFile % last_index)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting Writing to" + ut.flowsFile)    
bigdf.to_parquet(ut.flowsFile, compression='gzip')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting Writing to" + ut.flowsFileCsv)    
bigdf.to_csv(ut.flowsFileCsv)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Complted Writing to" + ut.flowsFileCsv)    
