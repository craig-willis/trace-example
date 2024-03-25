# gpg --full-generate-key
# export GPG_FINGERPRINT=
# export GPG_PASSPHRASE=
# export FRED_APIKEY=

rm trace-fred.*
rm workflow.png

echo ">> Prepare test repository"

git clone https://github.com/craig-willis/trace-fred /tmp/trace-fred

rm -rf /tmp/trace-fred/.git
rm /tmp/trace-fred/.gitignore

echo $FRED_APIKEY > /tmp/trace-fred/fred_apikey.txt

echo ">> Run workflow"

tro-utils --declaration trace-fred.jsonld \
  --profile trs.jsonld \
  --tro-creator "Craig Willis" \
  --tro-name "FRED API Example" \
  --tro-description "Analysis and visualization of S&P500 data using FRED API. S&P 500 data is copyrighted and redistribution is not permitted without permission. The analysis requires use of a private FRED API key that cannot be redistributed." \
  arrangement add /tmp/trace-fred -m "Before executing workflow" 

echo ">> Run workflow"
START=`date +"%Y-%m-%dT%H:%M:%S"` 
pushd /tmp/trace-fred && \
  sh run.sh && \
  popd
END=`date +"%Y-%m-%dT%H:%M:%S"` 
tro-utils --declaration trace-fred.jsonld --profile trs.jsonld arrangement add /tmp/trace-fred -m "After executing workflow"

tro-utils --declaration trace-fred.jsonld \
  performance add -m "Executed workflow" \
  -s $START \
  -e $END \
  -a arrangement/0 -M arrangement/1 

echo ">> Remove restricted files"
START=`date +"%Y-%m-%dT%H:%M:%S"`
rm -rf /tmp/trace-fred/fred_apikey.txt 
rm -rf /tmp/trace-fred/data/*
END=`date +"%Y-%m-%dT%H:%M:%S"`

tro-utils --declaration trace-fred.jsonld --profile trs.jsonld arrangement add /tmp/trace-fred -m "After removing restricted files" 

tro-utils --declaration trace-fred.jsonld \
  performance add -m "Removal of restricted files" \
  -s $START -e $END \
  -a arrangement/1 -M arrangement/2 


echo ">> Zip artifacts"
pushd /tmp/trace-fred && \
  zip -r trace-fred.zip . && \
  popd

mv /tmp/trace-fred/trace-fred.zip .

echo ">> Sign declaration"
tro-utils --declaration trace-fred.jsonld sign

echo ">> Verify declaration"
tro-utils --declaration trace-fred.jsonld verify

echo ">> SHACL validation"
pyshacl -s https://raw.githubusercontent.com/transparency-certified/trov/main/0.1/trov_shacl.ttl -f human -df json-ld trace-fred.jsonld


echo ">> Generate Report"
tro-utils --declaration trace-fred.jsonld report --template tro.md.jinja2 -o trace-fred.md

echo ">> Remove temporary files"
rm -rf /tmp/trace-fred
