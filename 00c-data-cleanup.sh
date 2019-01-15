# 20180528-patentsview clean up steps
location.tsv patent.tsv rawlocation.tsv rawinventor.tsv uspatentcitation.tsv have lines with unmatched quotes. Look up bad.file generated in the earlier step, and manually correct for the unmatched double quotes, "", as well as misplaced tab spaces in the six patent.tsv entries - all using Hex Fiend

patent.tsv has five instances of the CF character appearing within the text (hex: 0D). Search for hex 0D in Hex Fiend and replace with space (Hex 20). 
