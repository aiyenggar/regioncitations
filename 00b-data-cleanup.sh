# 20180528-patentsview clean up steps
DATADIR=$HOME/data/20180528-patentsview
FILES="location.tsv rawlocation.tsv rawinventor.tsv"

awk -F"\t" '{$6=""; print}' $DATADIR/patent.tsv > $DATADIR/cle.patent.tsv

for file in $FILES
do
  awk -F\" 'NF % 2 == 0' $DATADIR/$file > $DATADIR/bad.$file
  awk -F\" 'NF % 2 != 0' $DATADIR/$file > $DATADIR/cle.$file
done

