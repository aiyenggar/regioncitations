#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 08:44:34 2019

@author: aiyenggar
"""
import csv
import pandas as pd
import geopy.distance

def dump(dictionary, filename):
    with open(filename, 'w') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(['latlong', 'urban_area', 'minimum_distance'])
        for nextkey in dictionary.keys():
            spl = nextkey.split(":")
            writer.writerow([spl[0], spl[1], dictionary[nextkey]])
        csvFile.close()

file_latlong_urbanarea="/Users/aiyenggar/processed/patents/latlong_urbanarea.csv"
file_filled_urbanarea="/Users/aiyenggar/processed/patents/nearby_urbanarea.csv"
latlong_urbanarea = pd.read_csv(file_latlong_urbanarea, usecols = ['latlong', 'latitude', 'longitude', 'urban_area', 'population', 'areakm'], dtype={'latlong':str, 'latitude':float, 'longitude':float, 'urban_area':str, 'population':int,'areakm':int})
latlong_urbanarea['mindist']=round(2 * 3.14159 * 6371,2)
latlong_urbanarea['near_latlong']=""
latlong_urbanarea['near_urbanarea']=""
latlong_urbanarea.sort_values(['latitude', 'longitude'], ascending=[True, True])
treshold = 0.5
master = latlong_urbanarea.copy(True)
master.dropna(subset=['urban_area'], inplace=True)
neighbours = {}
for mindex, masterow in master.iterrows():
    a = masterow['latitude']
    b = masterow['longitude']
    l=(a,b)

    for nindex, nrow in latlong_urbanarea[(latlong_urbanarea['latitude'] < a + treshold) & (latlong_urbanarea['latitude'] > a - treshold) & (latlong_urbanarea['longitude'] < b + treshold) & (latlong_urbanarea['longitude'] > b - treshold)].iterrows():
        if (pd.isnull(nrow['urban_area'])):
            r=(nrow['latitude'], nrow['longitude'])
            dist = round(geopy.distance.geodesic(l,r).km,2)
            key = nrow['latlong']+":"+masterow['urban_area']
            if key in neighbours:
                current = neighbours[key]
                if dist < current:
                    neighbours[key] = dist
            else:
                neighbours[key] = dist

    if (mindex%100 == 0):
        print(str(mindex))
        dump(neighbours, file_filled_urbanarea)
dump(neighbours, file_filled_urbanarea)

