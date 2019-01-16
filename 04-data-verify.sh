
CURDIR=$PWD
DATADIR=$HOME/data/20180528-patentsview

FILES="application assignee location nber patent_assignee patent_inventor patent rawassignee rawinventor rawlocation uspatentcitation uspc_current"
cd $DATADIR
for file in $FILES
do
  echo $file.tsv
  awk -F\" 'NF % 2 == 0' $DATADIR/$file.tsv
done
cd $CURDIR
