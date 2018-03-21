#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 11:55:30 2018

@author: aiyenggar
"""
import sys
import os
import datetime.datetime
import subprocess
import csv
import numpy as np
import pandas as pd

def linetest(strname, pdname):
    pipe = subprocess.Popen("wc -l " + strname, shell=True, stdout=subprocess.PIPE).stdout
    filelen = pipe.read()
    pdlen = len(pdname)
    print(str(pdlen) + " " + str(filelen))
    # TODO This function should highlight a PASS OR FAIL status
    return [pdlen, filelen]

datapath="/Users/aiyenggar/data/20171226-patentsview/"
interpath="/Users/aiyenggar/intermediate-datafiles/patents/"

file_locationid_region= interpath + "locationid_urbanareas.csv"
file_application = datapath + "application.tsv"
#file_location = datapath + "location.tsv"
file_rawlocation = datapath + "1rawlocation.tsv"
file_rawinventor = datapath + "1rawinventor.tsv"
file_rawassignee = datapath + "rawassignee.tsv"
file_patent_inventor = datapath + "patent_inventor.tsv"
file_nber = datapath + "nber.tsv"
file_uspc_current = datapath + "uspc_current.tsv"

strlist = [file_locationid_region, file_application, file_rawlocation, file_rawinventor, file_rawassignee, file_patent_inventor, file_nber, file_uspc_current]

locationid_region = pd.read_csv(file_locationid_region, usecols = ['id', 'name_conve', 'city', 'country'], dtype={'id':str, 'name_conve':str, 'city':str, 'country':str})
patent_inventor = pd.read_table(file_patent_inventor, usecols = ['patent_id', 'inventor_id'], dtype={'patent_id':str,'inventor_id':str})
application = pd.read_table(file_application, usecols = ['patent_id', 'date'], dtype={'patent_id':str, 'date':datetime})
rawlocation = pd.read_table(file_rawlocation, usecols = ['id', 'location_id'], dtype={'id':str, 'location_id':str})
rawinventor = pd.read_table(file_rawinventor, usecols = ['patent_id', 'inventor_id', 'rawlocation_id', 'name_first', 'name_last'], dtype={'patent_id':str, 'inventor_id':str, 'rawlocation_id':str, 'name_first':str, 'name_last':str})
rawassignee = pd.read_table(file_rawassignee, usecols = ['patent_id', 'assignee_id'], dtype={'patent_id':str, 'assignee_id':str})
nber = pd.read_table(file_nber, usecols = ['patent_id', 'category_id', 'subcategory_id'], dtype={'patent_id':str, 'category_id':int, 'subcategory_id':str})
uspc_current = pd.read_table(file_uspc_current, usecols = ['patent_id', 'mainclass_id', 'subclass_id', 'sequence'], dtype={'patent_id':str, 'mainclass_id':str, 'subclass_id':str, 'sequence':str})

pdlist = [locationid_region, application, rawlocation, rawinventor, rawassignee, patent_inventor, nber, uspc_current]
#output = map(linetest, strlist, pdlist) # TODO Figure out how to get map to work
for index in range(len(strlist)):
    linetest(strlist[index], pdlist[index])



file_uspatentcitation = datapath + "uspatentcitation.tsv"
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

