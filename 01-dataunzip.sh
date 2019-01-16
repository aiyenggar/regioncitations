CURDIR=$PWD
DATADIR=$HOME/data/20180528-patentsview
DELDIR=$DATADIR/data
UNZIPDIR=$DATADIR/data/20180528/bulk-downloads
FILES="application assignee location nber patent_assignee patent_inventor patent rawassignee rawinventor rawlocation uspatentcitation uspc_current"
for file in $FILES
do
  cd $DATADIR
  unzip $DATADIR/$file.tsv.zip && rm $DATADIR/$file.tsv.zip
done
mv $UNZIPDIR/* $DATADIR
rm -rf $DELDIR
cd $CURDIR
