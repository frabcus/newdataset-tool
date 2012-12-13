#!/bin/sh

set -e

boxname=$(whoami | sed 's:\.:/:')

# spreadsheet-install.sh
# Installs the ScraperWiki spreadsheet tool into this box.

(
cd ~/http

cat > index.html <<EOF
<html>
<head>
    <link rel="stylesheet" href="http://x.scraperwiki.com/vendor/style/bootstrap.min.css">
    <link rel="stylesheet" href="http://x.scraperwiki.com/style/metro.bootstrap.css">
</head>
<body style="background: transparent">
<div class="alert alert-success alert-block container">
<h4>Blank dataset created!</h4>
<p>
Add your SSH key using</p> 
<pre>curl --data-urlencode sshkey@\$(printf ~/.ssh/id_[rd]sa.pub) --data apikey=<apikey> http://box.scraperwiki.com/${boxname}/sshkeys"</pre>
<p>
Then SSH in to <a href="ssh://$(whoami)@box.scraperwiki.com">$(whoami)@box.scraperwiki.com</a>
</p>
</div>
</body>
</html>
EOF

if test -e spreadsheet-tool
then
  # Should only get here in testing.
  (
  cd spreadsheet-tool
  git pull
  )
else
  git clone git://github.com/scraperwiki/spreadsheet-tool.git
fi

sed -i "/^sqliteEndpoint/s@.*@sqliteEndpoint = '../../sqlite'; // Added by spreadsheet-install.sh@" spreadsheet-tool/js/spreadsheet-tool.js
)

# Install CSV download tool.
# :todo: Should really be in its own github repo.
cat > download << 'EOF'
#!/bin/sh
# Generated by install-extras.sh
tool=highrise
dbfile=~/${tool}/scraperwiki.sqlite
tables=$(sqlite3 $dbfile 'select name from sqlite_master where type="table" or type="view"')
for name in $tables
do
sqlite3 -header -csv $dbfile "select * from $name" > "http/$tool-$name.csv"
done
set -- $tables
if [ $# = 0 ]
then
printf '[]'
exit 0
fi
printf '['
while [ $# -gt 1 ]
do
printf '"%s-%s.csv",' $tool $1
shift
done
printf '"%s-%s.csv"' $tool $1
printf ']'
EOF
chmod +x download

