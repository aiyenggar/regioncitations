# 20180528-patentsview clean up steps
DATADIR=$HOME/data/20180528-patentsview
FILES="location.tsv patent.tsv rawlocation.tsv rawinventor.tsv"

for file in $FILES
do
  awk -F\" 'NF % 2 == 0' $DATADIR/$file > $DATADIR/bad.$file
done

awk -F"\t" '{$1="";$5="";$7="";print}' uspatentcitation.tsv  > processed.uspatentcitation.tsv

# I open each of the bad.$file manually and run :1,$s/"//g
# then concatenate the processed.$file and bad.$file into $file after backing up $file into original folder

# cat processed.location.tsv bad.location.tsv > location.tsv
# cat processed.rawinventor.tsv bad.rawinventor.tsv > rawinventor.tsv
# cat processed.rawlocation.tsv bad.rawlocation.tsv > rawlocation.tsv
# cat processed.patent.tsv bad.patent.tsv > n.patent.tsv
# the n.patent.tsv file will need post processing (below) after concatenation
#awk -F"\t" '{$6=""; print}' $DATADIR/n.patent.tsv > $DATADIR/patent.tsv
# n.patent.tsv which is the cleanedup version of the original can be moved to original

# Important
# About a 100 lines in location.tsv have matched quotes but they mess up with the lat long. So run :1,$s/"//g on location.tsv
