#!/bin/bash

while read assign; do
 export "$assign";
done < <(sed -nE 's/([a-z_0-9]+): (.*)/\1=\2/ p' pipeline-parameters.yaml)

aws secretsmanager create-secret --name $stackname --secret-string file://secrets.json --kms-key-id $secretsKeyArn

aws s3 cp . s3://$s3Bucket/$pipelineFilesPath/ --recursive
aws cloudformation create-stack --stack-name $stackName --template-url https://s3.amazonaws.com/$s3Bucket/$pipelineFilesPath/cloudformation.yaml --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $stackName
codepipelineRoleArn=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].Outputs[?OutputKey=='CodePipelineRoleArn'].OutputValue" --output text)
echo $codepipelineRoleArn
aws kms create-grant --key-id $secretsKeyArn --operations Decrypt Encrypt GenerateDataKey --grantee-principal $codepipelineRoleArn --name $stackName-grant

aws s3 rm s3://$s3Bucket/$pipelineFilesPath
