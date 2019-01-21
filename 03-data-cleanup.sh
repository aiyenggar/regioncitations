# 20180528-patentsview clean up steps
# As of 2019-01-21 location.tsv is not being used and can be ignored
location.tsv patent.tsv rawlocation.tsv rawinventor.tsv uspatentcitation.tsv have lines with unmatched quotes. Look up bad.file generated in the earlier step, and manually correct for the unmatched double quotes, "", as well as misplaced tab spaces in the six patent.tsv entries - all using Hex Fiend

patent.tsv has five instances of the CF character appearing within the text (hex: 0D). Search for hex 0D in Hex Fiend and replace with space (Hex 20). 
patent_id 8288508 8331281 8341296 have a tab within the title field that is causing an extra field to be read. Delete the Hex 09 that is unnecessary

