#!/bin/bash

while read assign; do
 export "$assign";
done < <(sed -nE 's/([a-z_0-9]+): (.*)/\1=\2/ p' pipeline-parameters.yaml)


aws s3 cp . s3://$s3Bucket/$pipelineFilesPath/ --recursive
aws cloudformation create-stack --stack-name $stackName --template-url https://s3.amazonaws.com/$s3Bucket/$pipelineFilesPath/cloudformation.yaml --parameters file://parameters.json --capabilities CAPABILITY_NAMED_IAM
codepipelineRoleArn=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].Outputs[?OutputKey=='CodePipelineRoleArn'].OutputValue" --output text)

aws kms create-grant --key-id arn:aws:kms:us-east-1:367644944967:key/mrk-0c3e558cf35f4c78affd6c71d9336604 --operations Decrypt Encrypt GenerateDataKey --grantee-principal $codepipelineRoleArn --name $stackName-grant
