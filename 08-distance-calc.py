#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 08:44:34 2019

@author: aiyenggar
"""
import csv
import pandas as pd
import geopy.distance
import time


def dump(dictionary, filename):
    with open(filename, 'w') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(['latlong', 'urban_area', 'minimum_distance'])
        for nextkey in dictionary.keys():
            spl = nextkey.split(":")
            writer.writerow([spl[0], spl[1], dictionary[nextkey]])
        csvFile.close()

# read the latlongid to ua1 mapping into latlong_urbanarea
latlong_urbanarea = pd.read_csv(ut.latlongUrbanAreaFile, usecols = ['latlongid', 'ua1', 'latitude', 'longitude'], dtype={'latlongid':int, 'ua1':int, 'latitude':float, 'longitude':float})

# set mindist to the circumference of the earth (a high value)
latlong_urbanarea['mindist']=round(2 * 3.14159 * 6371,2)
latlong_urbanarea['near_latlong']=""
latlong_urbanarea['near_urbanarea']=""
latlong_urbanarea.sort_values(['latitude', 'longitude'], ascending=[True, True])
# we want to restrict our search for an urban area nearby to a bounding box +- 0.3 degrees on latitutde but not longitude
treshold = 0.30
dist_dict = {}
# master is that pandas table where the point is already identified within an urbanarea
master = latlong_urbanarea[latlong_urbanarea['ua1'] != -1]
missing = latlong_urbanarea[latlong_urbanarea['ua1'] == -1]

csvFile = open(ut.distancesFile, 'w')
writer = csv.writer(csvFile)
writer.writerow(['l_latlongid', 'r_latlongid', 'distance'])
neighbours = {}
prev_line_seen=0
treshold_lines=1500
max_lines = len(latlong_urbanarea.index)
# we look for unlabelled points in the vicinity of labelled points (rather than the other way)
for mindex, masterow in master.iterrows():
    a = masterow['latitude']
    b = masterow['longitude']
    l=(a,b)
#   all unlabelled points within the bounding box of this labelled point
    lowert = a - treshold
    highert = a + treshold
    cutdf = missing[(missing['latitude'] < highert) & (missing['latitude'] > lowert)]
    for nindex, nrow in cutdf.iterrows():
        c = nrow['latitude']
        d = nrow['longitude']
        r=(c, d)
        key = tuple([a, b, c, d])
        if key not in dist_dict:
            distance = round(geopy.distance.geodesic(l,r).km,2)
            dist_dict[key] = distance
            # save all the calculated distances so as to avoid calculating again
            if dist_dict[key] < 30.01: # need to write only once
                writer.writerow([nrow['latlongid'], masterow['latlongid'], dist_dict[key]])
    if (mindex > prev_line_seen + treshold_lines):
        print(time.strftime("%Y-%m-%d %H:%M:%S") + " Processed  till index " + str(mindex) + " of " + str(max_lines))
        prev_line_seen = mindex
        csvFile.flush()
        dist_dict = {}
csvFile.close()
