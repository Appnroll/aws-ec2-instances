#!/bin/bash

# first argument $1 "aws_instances"
DATABASE=$1
# second argument $2, "aws_rds"
TABLE_NAME=$2

if [ -z "$1" ]
  then
    echo "No DATABASE supplied in first argument, will be aws_instances"
    DATABASE="aws_instances"
fi

if [ -z "$2" ]
  then
    echo "No TABLE_NAME supplied in second argument, will be aws_rds"
    TABLE_NAME="aws_rds"
fi


SAVED_FIELDS="dbi_resource_id, identifier, instance_class, region, profile"
# collects the regions to display them in the end of script
REGIONS_WITH_INSTANCES=""

# here we have ec2 describe-regions - but returns also rds regions
for region in `aws ec2 describe-regions --output text | cut -f3`
do
     # this mappping depends on describe-instances command output
     INSTANCE_ATTRIBUTES="{
       identifier: .DBInstanceIdentifier,
       dbi_resource_id: .DbiResourceId,
       instance_class: .DBInstanceClass,
       \"region\": \"$region\",
       \"profile\": \"$AWS_PROFILE\"
     }"


     echo -e "\nListing AWS RDS Instances in region:'$region'..."

     JSON=".DBInstances[] | ( $INSTANCE_ATTRIBUTES )"
     INSTANCE_JSON=$(aws rds describe-db-instances --region $region)

     if echo $INSTANCE_JSON | jq empty; then

          # "Parsed JSON successfully and got something other than false/null"
          OUT="$(echo $INSTANCE_JSON | jq $JSON)"

          # check if empty
          if [[ ! -z "$OUT" ]] then
            for row in $(echo "${OUT}" | jq -c "." ); do
              psql -c "INSERT INTO $TABLE_NAME($SAVED_FIELDS) SELECT $SAVED_FIELDS from json_populate_record(NULL::$TABLE_NAME, '${row}') ON CONFLICT (dbi_resource_id)
                DO UPDATE
                SET identifier = EXCLUDED.identifier,
                instance_class = EXCLUDED.instance_class,
                dbi_resource_id = EXCLUDED.dbi_resource_id,
                region = EXCLUDED.region,
                profile = EXCLUDED.profile
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
