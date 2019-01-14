
CURDIR=$PWD
DATADIR=$HOME/data/20180528-patentsview

FILES="application assignee location rawlocation rawinventor rawassignee patent_inventor patent_assignee nber uspc_current patent uspatentcitation"
cd $DATADIR
for file in $FILES
do
  echo $file.tsv
  awk -F\" 'NF % 2 == 0' $DATADIR/$file.tsv
done
cd $CURDIR
