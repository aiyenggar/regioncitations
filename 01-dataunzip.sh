CURDIR=$PWD
DATADIR=$HOME/data/20180528-patentsview
DELDIR=$DATADIR/data
UNZIPDIR=$DATADIR/data/20180528/bulk-downloads
# 2019-01-21 We have workarounds to using location.tsv and nber.tsv so they are being dropped. It is also not clear if patent_assignee and patent_inventor are being used
FILES="application assignee patent_assignee patent_inventor patent rawassignee rawinventor rawlocation uspatentcitation uspc_current ipcr"
for file in $FILES
do
  cd $DATADIR
  unzip $DATADIR/$file.tsv.zip && rm $DATADIR/$file.tsv.zip
done
mv $UNZIPDIR/* $DATADIR
rm -rf $DELDIR
cd $CURDIR
