#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 15:10:34 2019

@author: aiyenggar
"""

import pandas as pd
%time temp = pd.read_csv("/Users/aiyenggar/processed/patents/20190314-citation.csv") 

import dask.dataframe as dd
%time df = dd.read_csv("/Users/aiyenggar/processed/patents/20190314-citation.csv")
