DATADIR=$HOME/data/20191231-patentsview
FILES="application assignee patent_assignee patent_inventor patent rawassignee rawinventor rawlocation uspatentcitation uspc_current"
echo `date` > $DATADIR/bad.file 
for file in $FILES
do
  echo $file.tsv >> $DATADIR/bad.file
  awk -F\" 'NF % 2 == 0' $DATADIR/$file.tsv >> $DATADIR/bad.file
done

