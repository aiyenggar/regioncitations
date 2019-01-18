#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 08:44:34 2019

@author: aiyenggar
"""

import sys
import os
from datetime import datetime
import subprocess
import csv
import numpy as np
import pandas as pd
import geopy.distance

file_latlong_urbanarea="/Users/aiyenggar/processed/patents/latlong_urbanarea.csv"
file_filled_urbanarea="/Users/aiyenggar/processed/patents/filled_urbanarea.csv"
latlong_urbanarea = pd.read_csv(file_latlong_urbanarea, usecols = ['latlong', 'latitude', 'longitude', 'urban_area'], dtype={'latlong':str, 'latitude':float, 'longitude':float, 'urban_area':str})
latlong_urbanarea['mindist']=round(2 * 3.14159 * 6371,2)
latlong_urbanarea['near_latlong']=""
latlong_urbanarea['near_urbanarea']=""

master = latlong_urbanarea.copy(True)
master.dropna(subset=['urban_area'], inplace=True)

for mindex, masterow in master.iterrows():
    a = masterow['latitude']
    b = masterow['longitude']
    l=(a,b)
    for findex, fitrow in latlong_urbanarea.iterrows():
        if (pd.isnull(fitrow['urban_area'])):
            if ((fitrow['latitude'] - masterow['latitude']) > 0.4):
                break
            r=(fitrow['latitude'], fitrow['longitude'])
            dist = round(geopy.distance.geodesic(l,r).km,2)
            if (dist < fitrow['mindist']):
                latlong_urbanarea.loc[findex,'mindist'] = dist
                latlong_urbanarea.loc[findex,'near_latlong'] = masterow['latlong']
                latlong_urbanarea.loc[findex,'near_urbanarea'] = masterow['urban_area']
    if (mindex%59 == 0):
        print(str(mindex))
        latlong_urbanarea.to_csv(file_filled_urbanarea)
latlong_urbanarea.to_csv(file_filled_urbanarea)