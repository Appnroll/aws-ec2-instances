## aws_ec2_instances_from_all_regions_to_db

This script lists all AWS instances in all regions and saves to PostgreSQL database. Tested that works not only on `zsh` but also on `sh`.

### Preconditions
We need at least PostgreSQL 9.5 as it supports upsert so update on conflict.

The script assumes you have configured the AWS CLI
https://aws.amazon.com/cli/

You need to have jq installed

#### For jq on Mac
`brew install jq`

### Usage

first create the database:

`createdb aws_ec2`

then create the table from the script in sql folder:

`psql aws_ec2 -f sql/aws_instances.sql`

then run the script:

`zsh aws_ec2_instances_from_all_regions_to_db.zsh $DATABASE $TABLE_NAME`

this script was an experiment to save data from AWS-CLI using pure bash scripts. 
I liked the idea that no ruby or node backend is needed, so the dependencies are limited to:
`aws-cli`
`jq`
`psql`
which you usually have installed anyway on your local environment.


before you need to create aws_ec2 database in postgres
with table `aws_instances` and fields as $SAVED_FIELDS

### Troubleshooting

you may get `Failed to parse JSON, or got false/null`
This means you probably don't have `jq` installed.


## run_script_for_multiple_profiles
Here is a script if you need to fetch the data from
multiple profiles. Just pass the names of your profiles to the `profiles`
array in the `run_script_for_multiple_profiles.zsh`

You can have an example config like this:

#### example ~/.aws/config
```
[profile profile_1]
region=us-east-2
output=json

[profile profile_2]
region=us-east-1
output=json
```

#### example ~/.aws/credentials
```
[profile_1]
aws_access_key_id = YOUR_PROFILE_1_KEY_HERE
aws_secret_access_key = YOUR_PROFILE_1_SECRET_ACCESS_KEY_HERE

[profile_2]
aws_access_key_id = YOUR_PROFILE_2_KEY_HERE
aws_secret_access_key = YOUR_PROFILE_2_SECRET_ACCESS_KEY_HERE
```


Resources:
* https://starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/
* https://stedolan.github.io/jq/tutorial/
* https://medium.com/cameron-nokes/working-with-json-in-bash-using-jq-13d76d307c4
* https://www.codementor.io/engineerapart/getting-started-with-postgresql-on-mac-osx-are8jcopb
* https://stackoverflow.com/questions/46695013/how-can-i-use-update-with-json-populate-record-in-postgresql
