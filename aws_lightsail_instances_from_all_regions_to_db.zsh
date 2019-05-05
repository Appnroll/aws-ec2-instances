#!/bin/bash

# first argument $1 "aws_instances"
DATABASE=$1
# second argument $2, "aws_lightsail"
TABLE_NAME=$2

if [ -z "$1" ]
  then
    echo "No DATABASE supplied in first argument, will be aws_instances"
    DATABASE="aws_instances"
fi

if [ -z "$2" ]
  then
    echo "No TABLE_NAME supplied in second argument, will be aws_lightsail"
    TABLE_NAME="aws_lightsail"
fi


SAVED_FIELDS="state, name, username, arn, ssh_key_name, public_ip_address, created_at, region, profile"
# collects the regions to display them in the end of script
REGIONS_WITH_INSTANCES=""

for region in `aws ec2 describe-regions --output text | cut -f3`
do
     # this mappping depends on describe-instances command output
     INSTANCE_ATTRIBUTES="{
          state: .state.name,
          name: .name,
          arn: .arn,
          username: .username,
          ssh_key_name: .sshKeyName,
          created_at: .createdAt,
          public_ip_address: .publicIpAddress,
          \"region\": \"$region\",
          \"profile\": \"$AWS_PROFILE\"
     }"

     echo -e "\nListing AWS Lightsail Instances in region:'$region'..."
     JSON=".instances[] | ( $INSTANCE_ATTRIBUTES )"
     INSTANCE_JSON=$(aws lightsail get-instances --region $region)
     echo $INSTANCE_JSON
     if echo $INSTANCE_JSON | jq empty; then

          # "Parsed JSON successfully and got something other than false/null"
          OUT="$(echo $INSTANCE_JSON | jq $JSON)"
          echo $OUT
          # check if empty
          if [[ ! -z "$OUT" ]] then
            for row in $(echo "${OUT}" | jq -c "." ); do
              psql -c "INSERT INTO $TABLE_NAME($SAVED_FIELDS) SELECT $SAVED_FIELDS from json_populate_record(NULL::$TABLE_NAME, '${row}') ON CONFLICT (arn)
                DO UPDATE
                SET state = EXCLUDED.state,
                name = EXCLUDED.name,
                username = EXCLUDED.username,
                created_at = EXCLUDED.created_at,
                public_ip_address = EXCLUDED.public_ip_address,
                profile = EXCLUDED.profile,
                region = EXCLUDED.region,
                ssh_key_name = EXCLUDED.ssh_key_name
                " -d $DATABASE
            done

            REGIONS_WITH_INSTANCES+="\n$region"
          else
            echo "No instances"
          fi
     else
          echo "Failed to parse JSON, or got false/null"
     fi
done

echo "Finished! Instances found in regions:"
echo $REGIONS_WITH_INSTANCES
