#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 13:36:30 2019

@author: aiyenggar
"""
import citationutils as ut
import dask.dataframe as dd
from dask.distributed import Client

if __name__ == "__main__":
    client = Client(n_workers=1, threads_per_worker=4, processes=False, memory_limit='2GB')
index = 2
df = dd.read_csv(ut.citationFlowsFile, usecols = ['year', 'uaid', 'patent_id', 'citation_id', 'q0', 'q1', 'q2', 'q3', 'q4', 'q5'], dtype={'year':int, 'uaid':int, 'patent_id':str, 'citation_id':str, 'q0':float, 'q1':float, 'q2':float, 'q3':float, 'q4':float, 'q5':float})

#Pull all entries by year

#Pull entries by originating patent

#Keep only one entry per uaid patent_id citation_id
client.close()
