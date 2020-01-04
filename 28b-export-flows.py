#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan  3 02:41:41 2020

@author: aiyenggar
"""

import citationutils as ut
import pandas as pd
import time

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Started Reading " + ut.flowsFile)     
bigdf = pd.read_parquet(ut.flowsFile)

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Starting Writing to " + ut.flowsFileCsv)    
bigdf.to_csv(ut.flowsFileCsv, index=False)
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Complted Writing to " + ut.flowsFileCsv)    
