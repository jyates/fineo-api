#!/usr/bin/env bash
# Run the templating and check the output against the set of files that we care about to
# determine if we need to push the apis

current="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# run the templating
./template/template.rb --output $current

# check each file against the current state
function check(){
  git sdiff | grep $1-swagger* | wc -l
}

function deploy(){
  updated=`check $1`
  if [ $updated -eq 1 ]; then
    echo "Deploying API: ${1}..."
    $current/deploy/deploy.rb --api $1 --stage test --credentials $CREDENTIALS --input $current
    $current/deploy/promote.rb --api $1 --stage test --credentials $CREDENTIALS
 fi
}

deploy "batch"
deploy "stream"`
deploy "read"
deploy "schema"`
deploy "schema-internal"

if [ `git sdiff | wc -l` -gt 0 ]; then
  git commit -m "Updated APIs through jenkins job $BUILD_ID"
  git push origin master
fi
