#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 08:44:34 2019

@author: aiyenggar
"""
import csv
import pandas as pd
import geopy.distance

basepath="/Users/aiyenggar/processed/patents/"
file_latlong_urbanarea=basepath+"latlong_urbanarea_1.csv"
file_filled_urbanarea=basepath+"latlong_distance.csv" # this file with stored distances between points is reused while processing citations, but this is subject to the +-0.3 bounding box

def dump(dictionary, filename):
    with open(filename, 'w') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(['latlong', 'urban_area', 'minimum_distance'])
        for nextkey in dictionary.keys():
            spl = nextkey.split(":")
            writer.writerow([spl[0], spl[1], dictionary[nextkey]])
        csvFile.close()

# read the latlongid to ua1 mapping into latlong_urbanarea
latlong_urbanarea = pd.read_csv(file_latlong_urbanarea, usecols = ['latlongid', 'ua1', 'latitude', 'longitude'], dtype={'latlongid':int, 'ua1':int, 'latitude':float, 'longitude':float})

# set mindist to the circumference of the earth (a high value)
latlong_urbanarea['mindist']=round(2 * 3.14159 * 6371,2)
latlong_urbanarea['near_latlong']=""
latlong_urbanarea['near_urbanarea']=""
latlong_urbanarea.sort_values(['latitude', 'longitude'], ascending=[True, True])
# we want to restrict our search for an urban area nearby to a bounding box +- 0.3 degrees on latitutde and longitude
treshold = 0.3

# master is that pandas table where the point is already identified within an urbanarea
master = latlong_urbanarea[latlong_urbanarea['ua1'] != -1]

csvFile = open(file_filled_urbanarea, 'w')
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
    for nindex, nrow in latlong_urbanarea[(latlong_urbanarea['ua1'] == -1) and (latlong_urbanarea['latitude'] < a + treshold) and (latlong_urbanarea['latitude'] > a - treshold) and (latlong_urbanarea['longitude'] < b + treshold) and (latlong_urbanarea['longitude'] > b - treshold)].iterrows():
        r=(nrow['latitude'], nrow['longitude'])
        dist = round(geopy.distance.geodesic(l,r).km,2)
        # save all the calculated distances so as to avoid calculating again
        writer.writerow([nrow['latlongid'], masterow['latlongid'], dist])
        # the first field, nrow['latlongid'] is one that is not matched to an urban area on a strict join
        # the second field, masterow['latlongid'] is one that is matched to an urban area on a strict join
    if (mindex > prev_line_seen + treshold_lines):
        print("Processed  till index " + str(mindex) + " of " + str(max_lines))
        prev_line_seen = mindex
        csvFile.flush()
csvFile.close()
