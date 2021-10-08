#!/bin/bash

while read assign; do
 export "$assign";
done < <(sed -nE 's/([a-z_0-9]+): (.*)/\1=\2/ p' pipeline-parameters.yaml)


aws cloudformation delete-stack --stack-name $stackName
