#!/bin/bash

APPSTACKID=`cat /etc/appstackid.conf`
TOKEN=`curl --silent -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AZ=`curl --silent -H "X-aws-ec2-metadata-token: $TOKEN"  http://169.254.169.254/latest/meta-data/placement/availability-zone`

rds_instance_id=`aws --region ${AZ::-1} ssm get-parameters --names ${APPSTACKID}_rdsinstanceid --query 'Parameters[0].Value' --output text`
rds_user=`aws --region ${AZ::-1} ssm get-parameters --names ${APPSTACKID}_rdsuser --query 'Parameters[0].Value' --output text`
rds_pass=`aws --region ${AZ::-1} ssm get-parameters --names ${APPSTACKID}_rdspass --query 'Parameters[0].Value' --output text --with-decryption`

rds_endpoint=`aws --region ${AZ::-1} rds describe-db-instances --db-instance-identifier $rds_instance_id | jq -r ".DBInstances[].Endpoint.Address"`
mysql -h $rds_endpoint -P 3306 -u $rds_user -p$rds_pass movies < $1

