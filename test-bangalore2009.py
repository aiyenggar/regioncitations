# -*- coding: utf-8 -*-
"""
Created on Sat Jan 14 11:36:49 2017

@author: aiyenggar
"""

import csv
import datetime

cpiFile="/Users/aiyenggar/datafiles/patents/2009.blr.rawinventor.csv"
#0-uuid,1-patent_id,2-citation_id,3-date,4-name,5-kind,6-country,7-category,8-sequence
searchFile="/Users/aiyenggar/datafiles/patents/uspatentcitation.applicant.csv"
    
# 0-patent_id,1-inventor_id,2-region,3-region_source,4-country,5-year
keysFile1="/Users/aiyenggar/datafiles/patents/rawinventor_region.csv"

#load up all citing patents and map to their inventors
citingPatentsDict=dict({})
cpf = open(cpiFile, 'r', encoding='utf-8')
cpr = csv.reader(cpf)

for cpline in cpr:
    patentid=cpline[0]
    inventorid=cpline[1]
    if (len(patentid)>0):
        if patentid in citingPatentsDict:
            current=citingPatentsDict[patentid]
            if (len(current)>0):
                citingPatentsDict[patentid]=current.append(inventorid)
            else:
                print(current)        
        else:
            if (len(inventorid)>0):
                citingPatentsDict[patentid]=list([inventorid])
            else:
                print("Missing inventor for patent "+patentid)
print(str(len(citingPatentsDict)))

cpf.close()
