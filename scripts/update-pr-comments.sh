#!/usr/bin/env bash

MESSAGE=`echo $1 | grep '^Plan:'`

OUTPUT="{\"body\":\"`echo ${MESSAGE} | sed 's/ /\\./g'`\"}"

curl -s -X POST -d ${OUTPUT} -H \
"Authorization: token ${SECRET}" \
"https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PULL_REQUEST_NUMBER}/comments"