"""
Created on Wed Feb  27 05:48:51 2019

@author: aiyenggar
"""

import sys
pathPrefix = "/Users/aiyenggar/processed/patents/"
#backwardCitationsConfig="Expanded"
backwardCitationsConfig="Pure-Collapsed"
fileDatePrefix="20200104"
urbanareaConfig="ua3"
calculateCitationDistanceString="dis"
distanceTreshold=30.01
latitudeDegreeTreshold=0.3 # to set the bounding box based on latitude and longitude
outputPrefix = fileDatePrefix + "-" + urbanareaConfig + "-" + calculateCitationDistanceString

veryLargeValue = sys.maxsize
update_freq_lines=10000000
#update_freq_lines=100
attributeErrorValue=['-2'] # List value is empty
keyErrorValue=['-3'] # No information
defaultErrorValue=['-4']
expandedCitationLastFileSuffix=1

# patent_id,cited_type1,cited_type2,cited_type3,cited_type4,cited_type5,precutoff_patents_cited,all_patents_cited,cnt_assignee,cnt_inventor,date_grant,date_application,year_application,year_grant
summaryFile=pathPrefix + "patent_summary.csv"
# patent_id,inventor_id,latlongid,uaid
patentUrbanAreaFile=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-patent.csv"
# patent_id,assignee_numid
patentAssigneeFile=pathPrefix + "patent-assignee-numid.csv"
# patent_id,assigneelist,latlonglist,ualist
keysFile1=pathPrefix + fileDatePrefix + "-" + urbanareaConfig + "-uaid-assignee-map.csv"
# patent_application_year,patent_id,citation_id,citation_type,sequence,kind,citation_application_year
searchFileName=pathPrefix + "8749084-citation.csv"
distancesFile=pathPrefix + "latlong-distance.csv"
latlongFile=pathPrefix + "latlong-urbanarea.csv"
# Within Cluster, Within Firm: q1
# Within Cluster, Outside Frim: q2
# Outside Cluster, Within Firm: q3
# Outside Cluster, Outside Firm: q4
# Not determinable: q5

inputfile22 = keysFile1
searchfile22 = searchFileName
outputfile22 = pathPrefix + outputPrefix + "-citations-received-by-patent.csv"
outputheader22 = ["citation_id", "patent_id", "uaid", "total_citations_received", "self_citations_received", "nonself_citations_received", "year"]
errorfile22 = pathPrefix + outputPrefix + "-err22.csv"
errorheader22 = ["patent_id", "field", "error_value", "num_raw_citations"]
citationDistanceUsedFileName = pathPrefix + outputPrefix + "-patent-citation-distance.csv"
#year,uaid,patent_id,citation_id,q0,q1,q2,q3,q4,q5
citationFlowsFile = pathPrefix + outputPrefix + "-citation-flows.csv"
citationFlowsParquet = pathPrefix + outputPrefix + "-citation-flows.parquet"
singleUaidFlowsFile = pathPrefix + outputPrefix + "-single-citation-flows-%s.parquet"
flowsFile = pathPrefix + outputPrefix + "-flows.parquet"
flowsFileCsv = pathPrefix + outputPrefix + "-flows.csv"
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
