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
file_location = datapath + "/location.tsv"
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
    print(str(l_uspatentcitation))
#    uspatentcitation = pd.DataFrame(l_uspatentcitation, columns = col_uspatentcitation)    
#    uspatentcitation
    if r_uspatentcitation.line_num == 10:
        break
