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
ldf = []
for last_index in range(1, maxindex + 1):
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Reading " + ut.singleUaidFlowsFile % last_index)
    ldf += [pd.read_parquet(ut.singleUaidFlowsFile % last_index)]
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " Read " + ut.singleUaidFlowsFile % last_index)
    
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Concatenating")     
bigdf = pd.concat(ldf)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting Writing to " + ut.flowsFile)    
bigdf.to_parquet(ut.flowsFile, compression='gzip')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting Writing to " + ut.flowsFileCsv)    
bigdf.to_csv(ut.flowsFileCsv)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Complted Writing to " + ut.flowsFileCsv)    
