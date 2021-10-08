#!/bin/bash

while read assign; do
 export "$assign";
done < <(sed -nE 's/([a-z_0-9]+): (.*)/\1=\2/ p' pipeline-parameters.yaml)


aws s3 cp . s3://$s3Bucket/$pipelineFilesPath/ --recursive
aws cloudformation update-stack --stack-name $stackName --template-url https://s3.amazonaws.com/$s3Bucket/$pipelineFilesPath/cloudformation.yaml --parameters file://parameters.json --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
