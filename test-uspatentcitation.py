# -*- coding: utf-8 -*-
"""
Created on Fri Jan 13 19:34:47 2017

@author: aiyenggar
"""
import csv
import datetime

printtreshold=1000000
#0-uuid,1-patent_id,2-citation_id,3-date,4-name,5-kind,6-country,7-category,8-sequence
searchFile="/Users/aiyenggar/datafiles/patents/uspatentcitation.applicant.csv"
yearFile="/Users/aiyenggar/Onedrive/data/patentsview/application.tsv"
#uuid	patent_id	inventor_id	rawlocation_id	name_first	name_last	sequence
inventorFile="/Users/aiyenggar/datafiles/patents/rawinventor.patentinventor.tsv"

outputFileHeader=["year", "citations_granted", "inventor_citations_granted", "patents_applied"]
outputFile="/Users/aiyenggar/datafiles/patents/uspatentcitation.year.csv"

patentyearDict=dict({})
appyearDict=dict({})

yearf = open(yearFile, 'r', encoding='utf-8')
yearreader = csv.reader(yearf, delimiter="\t")
for yearline in yearreader:
    if yearreader.line_num == 1:
        continue
    patentid = yearline[1]
    longdate = yearline[5]
    if (len(longdate) > 0):
        dateobj=datetime.datetime.strptime(longdate, '%Y-%m-%d')
        year=dateobj.year
        if (len(patentid) > 0):
            if patentid in patentyearDict:
                print("Duplication for patent: " + patentid + " previous year " + appyearDict[year] + "now got " + year)
            else:
                patentyearDict[patentid] = year
                if year in appyearDict:
                    appyearDict[year] = appyearDict[year] + 1
                else:
                    appyearDict[year] = 1
    if yearreader.line_num % printtreshold == 0:
        print("Processed " + str(yearreader.line_num) + " lines")
        
        
yearf.close()

patentinventorDict=dict({})
inventorf = open(inventorFile, 'r', encoding='utf-8')
inventorreader = csv.reader(inventorf, delimiter=" ")
for inventorline in inventorreader:
    if inventorreader.line_num == 1:
        continue
    patentid = inventorline[0]
    inventorid = inventorline[1]
    if len(patentid) > 0 and len(inventorid) > 0:
        if patentid in patentinventorDict:
            patentinventorDict[patentid] = patentinventorDict[patentid] + 1
        else:
            patentinventorDict[patentid] = 1    
    if inventorreader.line_num % printtreshold == 0:
        print("Processed " + str(inventorreader.line_num) + " lines")      
inventorf.close()

searchf = open(searchFile, 'r', encoding='utf-8')
sreader = csv.reader(searchf)

yearcitationDict=dict({})
missingcitedpatentDict=dict({})
missingcitingpatentDict=dict({})

for entry in sreader:
    if sreader.line_num == 1:
        continue
    patentid=entry[1]
    citationid=entry[2]
    longdate=entry[3]
    if (len(patentid) > 0 and len(citationid) > 0 and len(longdate) > 0):
        inventorcitations=0
        if (patentid in patentinventorDict):
            if (citationid in patentinventorDict):
                inventorcitations=patentinventorDict[patentid] * patentinventorDict[citationid]
            else:
                if citationid in missingcitedpatentDict:
                    missingcitedpatentDict[citationid]=missingcitedpatentDict[citationid]+1
                else:
                    missingcitedpatentDict[citationid]=1
        else:
            if patentid in missingcitingpatentDict:
                missingcitingpatentDict[patentid]=missingcitingpatentDict[patentid] + 1
            else:
                missingcitingpatentDict[patentid]=1

        dateobj=datetime.datetime.strptime(longdate, '%Y-%m-%d')
        year=dateobj.year
        if year in yearcitationDict:
            current = yearcitationDict[year]
            yearcitationDict[year]=[current[0]+1, current[1]+inventorcitations]
        else:
            yearcitationDict[year] = [1, inventorcitations]

    if sreader.line_num % printtreshold == 0:
        print("Processed " + str(sreader.line_num) + " lines")
searchf.close()



outputf = open(outputFile, 'w', encoding='utf-8')
writer = csv.writer(outputf)
writer.writerow(outputFileHeader)
for year in sorted(yearcitationDict.keys()):
    if year in appyearDict:
        yc=yearcitationDict[year]
        ya=appyearDict[year]
        writer.writerow([year, yc[0], yc[1], ya])
    else:
        print("No " + str(year) + " in the application data")
outputf.close()

if len(missingcitingpatentDict)>0:
    errorf = open("missing-citingpatents.csv", 'w', encoding='utf-8')
    writer = csv.writer(errorf)
    for patent in missingcitingpatentDict:
        writer.writerow([patent, missingcitingpatentDict[patent]])
    errorf.close()

if len(missingcitedpatentDict)>0:
    errorf = open("missing-citedpatents.csv", 'w', encoding='utf-8')
    writer = csv.writer(errorf)
    for patent in missingcitedpatentDict:
        writer.writerow([patent, missingcitedpatentDict[patent]])
    errorf.close()
