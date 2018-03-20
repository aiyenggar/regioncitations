#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 18:19:42 2018

@author: aiyenggar
"""

import shapefile
from Shapely.geometry import Point # Point class
from Shapely.geometry import shape # shape() is a function to convert geo objects through the interface

point = (38.8338889,-104.8208333) # an x,y tuple
shp = shapefile.Reader('/Users/aiyenggar/data/4.0.0-urban-areas/ne_10m_urban_areas_landscan.shp') #open the shapefile
all_shapes = shp.shapes() # get all the polygons
all_records = shp.records()
for i in len(all_shapes):
    boundary = all_shapes[i] # get a boundary polygon
    if Point(point).within(shape(boundary)): # make a point and see if it's in the polygon
       name = all_records[i][2] # get the second field of the corresponding record
       print("The point is in " + name)