#!/bin/bash

## these array contains profiles defined in .aws/config and .aws/credentials
declare -a profiles=("default" "appnroll")

DATABASE="aws_instances"
TABLE_NAME="aws_ec2"

PREVIOUS_PROFILE=$AWS_PROFILE
for aws_profile in "${profiles[@]}"
do
   echo -e "\nSaving AWS EC2 Instances from aws profile:'$aws_profile'..."
   export AWS_PROFILE=$aws_profile
   zsh aws_ec2_instances_from_all_regions_to_db.zsh $DATABASE $TABLE_NAME
done


## return to previous profile
export AWS_PROFILE=$PREVIOUS_PROFILE

psql -c "COPY $TABLE_NAME TO '$HOME/$TABLE_NAME.csv' DELIMITER ',' CSV HEADER;" -d $DATABASE
cd $HOME
open "$TABLE_NAME.csv"
