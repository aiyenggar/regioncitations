# https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=AIzaSyD2pVsDP1ocZZC4FpbguZq1_-9wmUtBKlY
from urllib.request import urlopen
import json

def getplace(lat, lon):
    key = "AIzaSyD2pVsDP1ocZZC4FpbguZq1_-9wmUtBKlY"
    url = "https://maps.googleapis.com/maps/api/geocode/json?"
    url += "latlng=%s,%s&sensor=false&key=%s" % (lat, lon, key)
    v = urlopen(url).read()
    j = json.loads(v)
    components = j['results'][0]['address_components']
    country = town = None
    for c in components:
        if "country" in c['types']:
            country = c['long_name']
        if "postal_town" in c['types']:
            town = c['long_name']

    return town, country

print(getplace(51.1, 0.1))
