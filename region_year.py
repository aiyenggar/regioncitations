#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 11:55:30 2018

@author: aiyenggar
"""
import sys
import csv
import numpy as np            
import pandas as pd

datapath="/Users/aiyenggar/data/20171226-patentsview/"
interpath="/Users/aiyenggar/intermediate-datafiles/patents"

file_locationid_region= interpath + "/locationid_urbanareas.csv" 
file_application = datapath + "/application.tsv" 
#file_location = datapath + "/location.tsv"
file_uspatentcitation = datapath + "/uspatentcitation.tsv"
file_rawlocation = datapath + "/rawlocation.tsv" 
file_rawinventor = datapath + "/rawinventor.tsv" 
file_rawassignee = datapath + "/rawassignee.tsv" 
file_patent_inventor = datapath + "/patent_inventor.tsv" 
file_nber = datapath + "/nber.tsv"

f_uspatentcitation = open(file_uspatentcitation, 'r', encoding='utf-8')
r_uspatentcitation = csv.reader(f_uspatentcitation, delimiter='\t')
for l_uspatentcitation in r_uspatentcitation:
    if r_uspatentcitation.line_num == 1:
        col_uspatentcitation = list(l_uspatentcitation)
        print("Header: " + str(col_uspatentcitation))
        continue
    uspatentcitation = pd.DataFrame([l_uspatentcitation], columns = col_uspatentcitation)
#    uspatentcitation.loc[0] = list(l_uspatentcitation)
    uspatentcitation = uspatentcitation[['patent_id', 'citation_id', 'date', 'category']]
    if r_uspatentcitation.line_num == 100:
        break

locationid_region = pd.read_csv(file_locationid_region, usecols = ['id', 'name_conve', 'city', 'country'])
patent_inventor = pd.read_table(file_patent_inventor, usecols = ['patent_id', 'inventor_id'])

application = pd.read_table(file_application, usecols = ['patent_id', 'date'])
rawlocation = pd.read_table(file_rawlocation, usecols = ['id', 'location_id'])
rawinventor = pd.read_table(file_rawinventor, usecols = ['patent_id', 'inventor_id', 'rawlocation_id', 'name_first', 'name_last'])
rawassignee = pd.read_table(file_rawassignee, usecols = ['patent_id', 'assignee_id'])

nber = pd.read_table(file_nber, usecols = ['patent_id', 'category_id', 'subcategory_id'])