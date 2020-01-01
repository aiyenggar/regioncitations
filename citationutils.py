"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import sys
pathPrefix = "/Users/aiyenggar/processed/patents/"
#backwardCitationsConfig="Expanded"
backwardCitationsConfig="Pure-Collapsed"
fileDatePrefix="20191230"
urbanareaConfig="ua3"
calculateCitationDistance=True
calculateCitationDistanceString="dis"
#calculateCitationDistance=False
#calculateCitationDistanceString="nod"
distanceTreshold=30.01
degreeTreshold=0.3 # to set the bounding box based on latitude and longitude
outputPrefix = fileDatePrefix + "-" + urbanareaConfig + "-" + calculateCitationDistanceString

veryLargeValue = sys.maxsize
update_freq_lines=15000000
#update_freq_lines=100
attributeErrorValue=['-2'] # List value is empty
keyErrorValue=['-3'] # No information
defaultErrorValue=['-4']
expandedCitationLastFileSuffix=1

#patent_id,cited_type1,cited_type2,cited_type3,cited_type4,cited_type5,precutoff_patents_cited,all_patents_cited,cnt_assignee,cnt_inventor,date_grant,date_application,year_application,year_grant
summaryFile=pathPrefix + "patent_summary.csv"
# the below file needs to be augmented to include a list of latlongid, so whenever uaid is -1, one may fall back onto the latlongid to then calculate the actual distance
# patent_id,assigneelist,latlonglist,ualist
keysFile1=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-patent_list_location_assignee.csv"
# year_application,patent_id,citation_id,citation_type,sequence,kind
searchFileName=pathPrefix + "citation.csv"
distancesFile=pathPrefix + "latlong_urbanarea_2.csv"
latlongFile=pathPrefix + "latlong_urbanarea.csv"
# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Within Firm: q3
# Outside Cluster, Outside Firm: q4
# Not determinable: q5

inputfile22 = keysFile1
searchfile22 = searchFileName
outputfile22 = pathPrefix + outputPrefix + "-patent-citation-received-by-year.csv"
outputheader22 = ["year", "patent_id", "total_citations_received", "self_citations_received", "nonself_citations_received"]
errorfile22 = pathPrefix + outputPrefix + "-err22.csv"
errorheader22 = ["patent_id", "field", "error_value", "num_raw_citations"]
citationDistanceUsedFileName = pathPrefix + outputPrefix + "-patent-citation-distance.csv"
#year,uaid,patent_id,citation_id,q0,q1,q2,q3,q4,q5
citationFlowsFile = pathPrefix + outputPrefix + "-citation-flows.csv"
citationFlowsParquet = pathPrefix + outputPrefix + "-citation-flows.parquet"
singleUaidFlowsFile = pathPrefix + outputPrefix + "-single-citation-flows.csv"
missing_dict = {} #global

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

def splitFromDict(key, fieldName, splitBy, dictionary):
    try:
        retVal = dictionary[fieldName][key].split(splitBy)
    except AttributeError:
        # we assume the value would have returned nan, implying a missing assignee field
        ekey = tuple([key, fieldName, attributeErrorValue[0]])
        if ekey not in missing_dict:
            missing_dict[ekey] = 0
        missing_dict[ekey] += 1
        retVal = attributeErrorValue
    except KeyError:
        ekey = tuple([key, fieldName, keyErrorValue[0]])
        if ekey not in missing_dict:
            missing_dict[ekey] = 0
        missing_dict[ekey] += 1
        retVal = keyErrorValue
    except:
        print(str(sys.exc_info()[0]) + " of " + fieldName + " -> " + key + " " + str(sys.exc_info()[1]))
        retVal = defaultErrorValue
    return retVal

# Assumes a return value of int
def readDict(key, fieldName, dictionary):
    try:
        retVal = dictionary[fieldName][key]
    except AttributeError:
        retVal = int(attributeErrorValue[0])
    except KeyError:
        retVal = int(keyErrorValue[0])
    except:
        print(str(sys.exc_info()[0]) + " [" + fieldName + "][" + key + "]" + str(sys.exc_info()[1]))
        retVal = int(defaultErrorValue[0])
    return retVal