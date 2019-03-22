"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import csv
import sys

#backwardCitationsConfig="Expanded"
backwardCitationsConfig="Pure-Collapsed"
fileDatePrefix="20190314"
urbanareaConfig="ua3"
calculateCitationDistance=True
calculateCitationDistanceString="dis"
#calculateCitationDistance=False
#calculateCitationDistanceString="nod"
distanceTreshold=30.01
degreeTreshold=0.3 # to set the bounding box based on latitude and longitude
outputPrefix = fileDatePrefix + "-" + urbanareaConfig + "-" + calculateCitationDistanceString
pathPrefix = "/Users/aiyenggar/processed/patents/"
veryLargeValue = sys.maxsize
update_freq_lines=15000000
attributeErrorValue=['-2'] # List value is empty
keyErrorValue=['-3'] # No information
defaultErrorValue=['-4']
expandedCitationLastFileSuffix=7

# the below file needs to be augmented to include a list of latlongid, so whenever uaid is -1, one may fall back onto the latlongid to then calculate the actual distance
# patent_id,assigneelist,latlonglist,ualist
keysFile1=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-patent_list_location_assignee.csv"
# application_year,patent_id,citation_id,citation_type,sequence,kind,application_date
searchFileName=pathPrefix + fileDatePrefix + "-citation.csv"
distancesFile=pathPrefix + "latlong_urbanarea_2.csv"
latlongFile=pathPrefix + "latlong_urbanarea.csv"
# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Outside Firm: q3
# Outside Cluster, Within Firm: q4
# Not determinable: q5

fc_outputheader=["uaid", "year", "citation_type", "fq1", "fq2", "fq3", "fq4", "fq5"]
fc_outputFileName=pathPrefix + outputPrefix + "-forward_citations.csv"

invErrorFileName=pathPrefix + outputPrefix + "-ErrInv.csv"
assErrorFileName=pathPrefix + outputPrefix + "-ErrAss.csv"

def dump(fName, dictionary, header, tolist):
    mapf = open(fName, 'w', encoding='utf-8')
    mapwriter = csv.writer(mapf)
    mapwriter.writerow(header)
    for key in dictionary:
        if tolist:
            l = list(key)
            r = list(dictionary[key])
        else:
            l = [key[0],key[1]]
            r = [str(dictionary[key])]
        mapwriter.writerow(l+r)
    mapf.close()
    return

def assign_flow(dictionary, fo_year, citationtype, focal_location, other_location, focal_assignee, other_assignee, avoid):
    if (focal_location >= 0) and (focal_location != avoid):
        key = tuple([focal_location, fo_year, citationtype])
        prior = [0, 0, 0, 0, 0]
        if key in dictionary:
            prior = dictionary[key]
        if (focal_assignee < 0) or (other_location < 0) or (other_assignee < 0):
            prior[4] += 1
        else:
            # Guaranteed that each of focal_location, other_location, focal_assignee, other_assignee are valid
            if focal_location == other_location:
                if focal_assignee == other_assignee:
                    prior[0] += 1
                else:
                    prior[1] += 1
            else:
                if focal_assignee == other_assignee:
                    prior[3] += 1
                else:
                    prior[2] += 1
        dictionary[key] = prior
    return dictionary

def assign_flow2(dictionary, fo_year, citationtype, focal_location, focal_assignee, other_assignee, avoid): #flow within assignee is marked on quadrant 1, and flow outside assignee is marked on quadrant 2
    if (focal_location >= 0) and (focal_location != avoid):
        key = tuple([focal_location, fo_year, citationtype])
        prior = [0, 0, 0, 0, 0]
        if key in dictionary:
            prior = dictionary[key]
        if (focal_assignee < 0) or (other_assignee < 0):
            prior[4] = 1 # quadrant 5
        else:
            if focal_assignee == other_assignee:
                prior[0] = 1 # quadrant 1
            else:
                prior[1] = 1 # quadrant 2
        dictionary[key] = prior
    return dictionary

def update(master_dictionary, updates_dict, default):
    for keys in updates_dict:
        change = updates_dict[keys]
        master = default
        if keys in master_dictionary:
            master = master_dictionary[keys]
        for index in range(0,5):
            master[index] += change[index]
        master_dictionary[keys] = master
    return master_dictionary


# Take a key and a dictionary, and increment the value against the key in the dictionary by one
def incrdict(key, dictionary):
    if key not in dictionary:
        dictionary[key] = 1
    else:
        dictionary[key] += 1
    return dictionary

def isValidUrbanArea(uaid):
    if (int(uaid) >= 0):
        return True
    return False

def isValidAssignee(assignee_id):
    if (int(assignee_id) >= 0):
        return True
    return False

def isValidLatLongId(latlongid):
    if (int(latlongid) >= 0):
        return True
    return False
