#!/bin/bash

# first argument $1 "aws_ec2"
DATABASE=$1
# second argument $2, "aws_instances"
TABLE_NAME=$2

if [ -z "$1" ]
  then
    echo "No DATABASE supplied in first argument, will be aws_ec2"
    DATABASE="aws_ec2"
fi

if [ -z "$2" ]
  then
    echo "No TABLE_NAME supplied in second argument, will be aws_instances"
    TABLE_NAME="aws_instances"
fi


SAVED_FIELDS="state, name, type, instance_id, public_ip, launch_time, region, profile, publicdnsname"

REGIONS_WITH_INSTANCES="" # collects the regions to display them in the end of script

for region in `aws ec2 describe-regions --output text | cut -f3`
do
     # this mappping depends on describe-instances command output
     INSTANCE_ATTRIBUTES="{
          state: .State.Name,
          name: .KeyName, type: .InstanceType,
          instance_id: .InstanceId,
          public_ip: .NetworkInterfaces[0].Association.PublicIp,
          launch_time: .LaunchTime,
          \"region\": \"$region\",
          \"profile\": \"$AWS_PROFILE\",
          publicdnsname: .PublicDnsName
     }"

     echo -e "\nListing AWS EC2 Instances in region:'$region'..."
     JSON=".Reservations[] | ( .Instances[] | $INSTANCE_ATTRIBUTES)"
     INSTANCE_JSON=$(aws ec2 describe-instances --region $region)
     # INSTANCE_JSON=$(aws ec2 describe-instances --region eu-west-1)

     if echo $INSTANCE_JSON | jq empty; then

          # "Parsed JSON successfully and got something other than false/null"
          OUT="$(echo $INSTANCE_JSON | jq $JSON)"

          # check if empty
          if [[ ! -z "$OUT" ]] then
            for row in $(echo "${OUT}" | jq -c "." ); do
              psql -c "INSERT INTO $TABLE_NAME($SAVED_FIELDS) SELECT $SAVED_FIELDS from json_populate_record(NULL::$TABLE_NAME, '${row}') ON CONFLICT (instance_id)
                DO UPDATE
                SET state = EXCLUDED.state,
                name = EXCLUDED.name,
                type = EXCLUDED.type,
                launch_time = EXCLUDED.launch_time,
                public_ip = EXCLUDED.public_ip,
                profile = EXCLUDED.profile,
                region = EXCLUDED.region,
                publicdnsname = EXCLUDED.publicdnsname
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
