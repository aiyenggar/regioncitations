#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 18:20:17 2018

@author: aiyenggar
"""

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