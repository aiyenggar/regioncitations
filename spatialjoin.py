#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 18:20:17 2018

@author: aiyenggar
"""

            
import numpy as np            
import pandas as pd
#import fiona
import geopandas
from geopandas import GeoDataFrame
from geopandas.tools import sjoin
from shapely.geometry import Point
#from shapely.geometry import shape

location = pd.read_table("/Users/aiyenggar/data/20171226-patentsview/location.tsv", usecols = [0, 4, 5])
location['latitude'] = pd.to_numeric(location['latitude'], errors='coerce')
location['longitude'] = pd.to_numeric(location['longitude'], errors='coerce')

#location[location.isnull().any(axis=1)]
location['latitude'] = np.where(location['longitude'].isnull(), np.nan, location['latitude'])
location['longitude'] = np.where(location['latitude'].isnull(), np.nan, location['longitude'])
location.dropna(inplace=True)
#location['longitude'] = location['longitude'].replace(np.nan, 0)


geometry = [Point(xy) for xy in zip(location.longitude, location.latitude)]
location = location.drop(['longitude', 'latitude'], axis=1)
crs = {'init' : 'epsg:4326'}
glocation = GeoDataFrame(location, crs=crs, geometry=geometry)

# , dtype = {'latitude': np.float32, 'longitude': np.float32}
urbancenters = geopandas.read_file("/Users/aiyenggar/data/4.0.0-urban-areas/ne_10m_urban_areas_landscan.shp")

# TODO: A given lat long can throw up more than one region. Example: Los Angeles1 and Pasadena2
# It may make sense to retain both and given both regions credit
locationid_region = sjoin(glocation.head(100), urbancenters, how="left", op='intersects')

locationid_region = locationid_region[['id', 'name_conve']]