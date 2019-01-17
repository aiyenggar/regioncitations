import googlemaps
from datetime import datetime

gmaps = googlemaps.Client(key='AIzaSyD2pVsDP1ocZZC4FpbguZq1_-9wmUtBKlY')

# Geocoding an address
#geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

# Look up an address with reverse geocoding
reverse_geocode_result = gmaps.reverse_geocode((40.714224, -73.961452))
components = reverse_geocode_result['results'][0]['address_components']
country = town = None
for c in components:
    if "country" in c['types']:
        country = c['long_name']
    if "postal_town" in c['types']:
        town = c['long_name']
print(country+", "+ "town")

# Request directions via public transit
now = datetime.now()
#directions_result = gmaps.directions("Sydney Town Hall", "Parramatta, NSW", mode="transit", departure_time=now)
