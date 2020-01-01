#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 13:36:30 2019

@author: aiyenggar
"""
import citationutils as ut
import dask.dataframe as dd
from dask.distributed import Client
import time


if __name__ == "__main__":
    client = Client(n_workers=1, threads_per_worker=2, processes=False, memory_limit='4GB')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Indexing")
df = dd.read_csv(ut.citationFlowsFile, \
                 usecols = ['year', 'uaid', 'patent_id', 'citation_id', 'q0', 'q1', 'q2', 'q3', 'q4', 'q5'], \
                     dtype={'year':int, 'uaid':int, 'patent_id':str, 'citation_id':str, 'q0':float, 'q1':float, 'q2':float, 'q3':float, 'q4':float, 'q5':float}).set_index('uaid')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Indexing")
df.to_parquet(ut.citationFlowsParquet, compression='gzip')
print(time.strftime("%Y-%m-%d %H:%M:%S") + " Completed Writing Parquet")

client.close()
