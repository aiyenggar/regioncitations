#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 19:38:36 2019

@author: aiyenggar
"""
import csv
import pandas as pd
import time
import dask.dataframe as dd
from dask.distributed import Client
import citationutils as ut

print(time.strftime("%Y-%m-%d %H:%M:%S") + " Beginning Pre-processing")
summary_dict = pd.read_csv(ut.summaryFile, usecols = ['patent_id','cited_type1','cited_type2','cited_type3','cited_type4','cited_type5','precutoff_patents_cited','all_patents_cited','cnt_assignee','cnt_inventor'], dtype={'patent_id':str,'cited_type1':int,'cited_type2':int,'cited_type3':int,'cited_type4':int,'cited_type5':int,'precutoff_patents_cited':int,'all_patents_cited':int,'cnt_assignee':int,'cnt_inventor':int}, index_col='patent_id').to_dict()





if __name__ == "__main__":
    client = Client(n_workers=1, threads_per_worker=4, processes=False, memory_limit='2GB')
index = 2
df = dd.read_csv("/Users/aiyenggar/data/20180528-patentsview/uspatentcitation.tsv", sep='\t', usecols = ['patent_id','citation_id','kind'], dtype={'patent_id':str,'citation_id':str,'kind':str})
pcited = df.groupby(['patent_id','kind'])['r_patent_id'].nunique().compute()
client.close()
