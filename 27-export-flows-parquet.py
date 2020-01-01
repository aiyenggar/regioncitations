#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 13:36:30 2019

@author: aiyenggar
"""
import citationutils as ut
import pandas as pd
import numpy as np
import dask.dataframe as dd
from dask.distributed import Client

if __name__ == "__main__":
    client = Client(n_workers=1, threads_per_worker=2, processes=False, memory_limit='2GB')
df = dd.read_csv(ut.citationFlowsFile, \
                 usecols = ['year', 'uaid', 'patent_id', 'citation_id', 'q0', 'q1', 'q2', 'q3', 'q4', 'q5'], \
                     dtype={'year':int, 'uaid':int, 'patent_id':str, 'citation_id':str, 'q0':float, 'q1':float, 'q2':float, 'q3':float, 'q4':float, 'q5':float})

df.to_parquet(ut.citationFlowsParquet)

"""
divyear = np.arange(1974,2020)
df_y = df.set_index('year', sorted=True).repartition(divisions=list(divyear))
#Pull all entries by year
year1980 = df_y[df_y['year'] == 1980]
retval1980 = year1980.to_csv('1980.csv')


#Pull entries by originating patent
onepat = df[df['patent_id'] == "7364810"]
onepat7364810 = onepat.to_csv('7364810.csv')

#Keep only one entry per uaid patent_id citation_id
onceuaid = df.drop_duplicates(subset=['uaid', 'patent_id', 'citation_id'], keep='first')
onceuaidretval = onceuaid.to_csv(ut.singleUaidFlowsFile)
"""
client.close()
