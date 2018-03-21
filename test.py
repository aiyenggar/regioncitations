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
       
       

import fiona
import shapely

with fiona.open("/Users/aiyenggar/data/4.0.0-urban-areas/ne_10m_urban_areas_landscan.shp") as fiona_collection:

    # In this case, we'll assume the shapefile only has one record/layer (e.g., the shapefile
    # is just for the borders of a single country, etc.).
    shapefile_record = fiona_collection.next()

    # Use Shapely to create the polygon
    shape = shapely.geometry.asShape( shapefile_record['geometry'] )

    point = shapely.geometry.Point(32.398516, -39.754028) # longitude, latitude

    # Alternative: if point.within(shape)
    if shape.contains(point):
        print("Found shape for point " + point)

import fiona        
with fiona.drivers():

    for layername in fiona.listlayers('/Users/aiyenggar/data/4.0.0-urban-areas'):
        with fiona.open('/Users/aiyenggar/data/4.0.0-urban-areas', layer=layername) as src:
            print(layername, len(src))
            
import fiona

with fiona.drivers():
    with fiona.open("/Users/aiyenggar/data/4.0.0-urban-areas/ne_10m_urban_areas_landscan.shp") as urbanareas:
        for area in urbanareas:
            print(area)