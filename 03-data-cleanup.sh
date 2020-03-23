# clean up steps
Look up bad.file generated in the earlier step, and manually correct for the unmatched double quotes using Hex Fiend
Previously patent.tsv had five instances of the CF character appearing within the text (hex: 0D). It was fixed by searching for hex 0D in Hex Fiend and replace with space (Hex 20). But this was not found in the 20191231 version. 

patent_id 8288508 8331281 8341296 have a tab within the title field that is causing an extra field to be read. Delete the Hex 09 that is unnecessary

