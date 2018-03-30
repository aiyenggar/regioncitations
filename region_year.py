#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 11:55:30 2018

@author: aiyenggar
"""
import sys
import os
from datetime import datetime
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
interpath="/Users/aiyenggar/processed/patents/"

file_locationid_region= interpath + "locationid_urbanareas.csv"
file_application = datapath + "application.tsv"
file_location = datapath + "location.tsv"
file_rawlocation = datapath + "rawlocation.tsv"
file_rawinventor = datapath + "rawinventor.tsv"
file_rawassignee = datapath + "rawassignee.tsv"
file_patent_inventor = datapath + "patent_inventor.tsv"
file_nber = datapath + "nber.tsv"
file_uspc_current = datapath + "uspc_current.tsv"
# awk -F"\t" '{$6=""; print}' ~/data/20171226-patentsview/patent.tsv > patent.noabstract.tsv
file_patent = datapath + "patent.noabstract.tsv"

strlist = [file_locationid_region, file_application, file_location, file_rawlocation, file_rawinventor, file_rawassignee, file_patent_inventor, file_nber, file_uspc_current, file_patent]

locationid_region = pd.read_csv(file_locationid_region, usecols = ['id', 'name_conve', 'city', 'country'], dtype={'id':str, 'name_conve':str, 'city':str, 'country':str})

patent_inventor = pd.read_table(file_patent_inventor, usecols = ['patent_id', 'inventor_id'], dtype={'patent_id':str,'inventor_id':str})

application = pd.read_table(file_application, usecols = ['patent_id', 'date'], dtype={'patent_id':str, 'date':str})
# application.dtypes
application['date'] = pd.to_datetime(application['date'], format='%Y-%m-%d', errors='coerce')
application = application.dropna()
application['year'] = pd.DatetimeIndex(application['date']).year

location = pd.read_table(file_location)

rawlocation = pd.read_table(file_rawlocation, usecols = ['id', 'location_id'], dtype={'id':str, 'location_id':str})

rawinventor = pd.read_table(file_rawinventor, usecols = ['patent_id', 'inventor_id', 'rawlocation_id', 'name_first', 'name_last'], dtype={'patent_id':str, 'inventor_id':str, 'rawlocation_id':str, 'name_first':str, 'name_last':str})

rawassignee = pd.read_table(file_rawassignee, usecols = ['patent_id', 'assignee_id'], dtype={'patent_id':str, 'assignee_id':str})

nber = pd.read_table(file_nber, usecols = ['patent_id', 'category_id', 'subcategory_id'], dtype={'patent_id':str, 'category_id':int, 'subcategory_id':str})

uspc_current = pd.read_table(file_uspc_current, usecols = ['patent_id', 'mainclass_id', 'subclass_id', 'sequence'], dtype={'patent_id':str, 'mainclass_id':str, 'subclass_id':str, 'sequence':str})

patent = pd.read_table(file_patent)

pdlist = [locationid_region, application, location, rawlocation, rawinventor, rawassignee, patent_inventor, nber, uspc_current, patent]
#output = map(linetest, strlist, pdlist) # TODO Figure out how to get map to work
for index in range(len(strlist)):
    linetest(strlist[index], pdlist[index])

# I need to create an appropriate data structure that captures variables at the region year level, even if not in aggregate. In a way that I just keep adding entries as I see them.


file_uspatentcitation = datapath + "uspatentcitation.tsv"
f_uspatentcitation = open(file_uspatentcitation, 'r', encoding='utf-8')
r_uspatentcitation = csv.reader(f_uspatentcitation, delimiter='\t')
for l_uspatentcitation in r_uspatentcitation:
    if r_uspatentcitation.line_num == 1:
        col_uspatentcitation = list(l_uspatentcitation)
#        print("Header: " + str(col_uspatentcitation))
        continue
    citn = pd.DataFrame([l_uspatentcitation], columns = col_uspatentcitation)
#    citn.loc[0] = list(l_uspatentcitation)
    citn = citn[['patent_id', 'citation_id', 'date', 'category']]
    citn['date'] = pd.to_datetime(citn['date'], format='%Y-%m-%d', errors='coerce')
    citn['year'] = pd.DatetimeIndex(citn['date']).year
#    citn['month'] = pd.DatetimeIndex(citn['date']).month

# Do the applicant year upfront or maybe this can be done with other patent level metrics

    # Get inventor id on either side; join citn with a limited dataframe selected on patentid
    # citing_rawinventor = rawinventor[rawinventor['patent_id'] == citn.iloc[0]['patent_id']]
    # cited_rawinventor = rawinventor[rawinventor['patent_id'] == citn.iloc[0]['citation_id']]
    #    patent_valuelist = [citn.iloc[0]['citation_id'], citn.iloc[0]['patent_id']]
    #    rawlocation_valuelist =citn_rawinventor['rawlocation_id'].unique()
    #    locationid_valuelist = citn_rawlocation['location_id'].unique()

    citn_rawinventor = rawinventor[rawinventor['patent_id'].isin([citn.iloc[0]['citation_id'], citn.iloc[0]['patent_id']])]

    citn_rawlocation = rawlocation[rawlocation['id'].isin(citn_rawinventor['rawlocation_id'])]

    citn_location = locationid_region[locationid_region['id'].isin(citn_rawlocation['location_id'])]

    pat_rawinventor = citn_rawinventor.rename(columns=lambda x: "p_" + x)
    cit_rawinventor = citn_rawinventor.rename(columns=lambda x: "c_" + x)

    citn = pd.merge(citn, pat_rawinventor, left_on='patent_id', right_on='p_patent_id', how='left')
    # save the above and change column names of the inventor columns. Use this as the left table below
    citn = pd.merge(citn, cit_rawinventor, left_on='citation_id', right_on='c_patent_id', how='left')
    citn['p_name'] = citn['p_name_first'] + " " + citn['p_name_last']
    citn['c_name'] = citn['c_name_first'] + " " + citn['c_name_last']
    citn = citn.drop(['p_patent_id', 'p_name_first', 'p_name_last', 'c_patent_id', 'c_name_first', 'c_name_last'], axis=1)

    citn['p_location_id'] = citn.p_rawlocation_id.replace(citn_rawlocation.set_index('id')['location_id'])
    citn['c_location_id'] = citn.c_rawlocation_id.replace(citn_rawlocation.set_index('id')['location_id'])

    citn_location = locationid_region[locationid_region['id'].isin(citn_rawlocation['location_id'])]

    pat_location = citn_location.rename(columns=lambda x: "p_" + x)
    cit_location = citn_location.rename(columns=lambda x: "c_" + x)


    citn = pd.merge(citn, pat_location, left_on='p_location_id', right_on='p_id', how='left')
    # save the above and change column names of the inventor columns. Use this as the left table below
    citn = pd.merge(citn, cit_location, left_on='c_location_id', right_on='c_id', how='left')
    citn = citn.drop(['p_id', 'c_id'], axis=1)

"""
    Turning out to miss the location_id
    citn = citn.set_index('p_location_id').join(pat_location.set_index('p_id'))
    citn = citn.set_index('c_location_id').join(cit_location.set_index('c_id'))
"""
    # Get locationid for the rawlocation_id for the inventors above. Find out how to select pandas rows that match of many values

"""
The following works for a one to one mapping. You can avoid a join. But in case you want to pull multiple fields then a join may become mandatory.

manip['p_location_id'] = manip.p_rawlocation_id.replace(citn_rawlocation.set_index('id')['location_id'])
manip['c_location_id'] = manip.c_rawlocation_id.replace(citn_rawlocation.set_index('id')['location_id'])
"""

    # From the location_id get the region name. patent -> inventor -> rawlocation -> location -> region
    print(citn)
    if r_uspatentcitation.line_num == 2:
        break

