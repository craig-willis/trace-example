#!/bin/bash
#
# This script executes the "trace-fred" workflow in the context of an 
# example TRACE System (TRS) and uses the tro-utils command-line tools
# to create and sign a Trusted Research Object (TRO).
#

# Remove old artifacts
mkdir -p tro
rm tro/*

echo ">> Prepare test repository"

git clone https://github.com/transparency-certified/trace-fred /tmp/trace-fred
# Exclude the .git folder and .gitignore file from the TRO
rm -rf /tmp/trace-fred/.git
rm /tmp/trace-fred/.gitignore

echo $FRED_APIKEY > /tmp/trace-fred/fred_apikey.txt

echo ">> Run workflow"

# Create a new TRO declaration and pre-execution arrangement
tro-utils --declaration tro/trace-fred.jsonld \
  --profile trs.jsonld \
  --tro-creator "Fred User" \
  --tro-name "FRED API Example" \
  --tro-description "Analysis and visualization of S&P500 data using FRED API. S&P 500 data is copyrighted and redistribution is not permitted without permission. The analysis requires use of a private FRED API key that cannot be redistributed." \
  arrangement add /tmp/trace-fred -m "Before executing workflow" 

# Run the example workflow
echo ">> Run workflow"
START=`date +"%Y-%m-%dT%H:%M:%S"` 
pushd /tmp/trace-fred && \
  sh run.sh && \
  popd
END=`date +"%Y-%m-%dT%H:%M:%S"` 

# Add post-execution arrangement
tro-utils --declaration tro/trace-fred.jsonld --profile trs.jsonld arrangement add /tmp/trace-fred -m "After executing workflow"

# Add a performance for the executed workflow
tro-utils --declaration tro/trace-fred.jsonld \
  performance add -m "Executed workflow" \
  -s $START \
  -e $END \
  -a arrangement/0 -M arrangement/1 

# Remove restricted files
echo ">> Remove restricted files"
START=`date +"%Y-%m-%dT%H:%M:%S"`
rm -rf /tmp/trace-fred/fred_apikey.txt 
rm -rf /tmp/trace-fred/data/*
END=`date +"%Y-%m-%dT%H:%M:%S"`

# Add arrangement after removing restrited riles
tro-utils --declaration tro/trace-fred.jsonld --profile trs.jsonld arrangement add /tmp/trace-fred -m "After removing restricted files" 

# Add a performance for restricted file removal
tro-utils --declaration tro/trace-fred.jsonld \
  performance add -m "Removal of restricted files" \
  -s $START -e $END \
  -a arrangement/1 -M arrangement/2 

# Package the redistributable artifacts
echo ">> Zip artifacts"
pushd /tmp/trace-fred && \
  zip -r trace-fred.zip . && \
  popd

mv /tmp/trace-fred/trace-fred.zip tro

# Sign the TRO
echo ">> Sign declaration"
tro-utils --declaration tro/trace-fred.jsonld sign

# Verify the TRO
echo ">> Verify declaration"
tro-utils --declaration tro/trace-fred.jsonld verify

# Generate the TRO report
echo ">> Generate Report"
tro-utils --declaration tro/trace-fred.jsonld report --template tro.md.jinja2 -o tro/trace-fred.md

# Clean up temporary files
echo ">> Remove temporary files"
rm -rf /tmp/trace-fred
