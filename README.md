## aws_ec2_instances_from_all_regions_to_db

This script lists all AWS instances in all regions and saves to PostgreSQL database. Tested that works not only on `zsh` but also on `sh`.

![](http://d1xu7knqe2z7f9.cloudfront.net/appnroll/all-ec2-instances.gif)

this script was an experiment to save data from AWS-CLI using pure bash scripts. 
I liked the idea that no ruby or node backend is needed, so the dependencies are limited to:

`aws-cli`

`jq`

`psql`

which you usually have installed anyway on your local environment.

### Prerequisites
We need at least PostgreSQL 9.5 as it supports `upsert` that is update on conflict. Commands `createdb` and `psql` come with it (not tested on Ubuntu, maybe it needs extension here).

#### install postgreSQL on Mac
`brew install postgresql`

The script assumes you have configured the AWS CLI
https://aws.amazon.com/cli/

You need to have `jq` installed

#### install jq on Mac
`brew install jq`

### Usage

0) make sure you have the preconditions

1) first create the database:

`createdb aws_ec2`

2) then create the table from the script in sql folder:

`psql aws_ec2 -f sql/aws_instances.sql`

before you need to run it to create `aws_ec2` database in postgres
with table `aws_instances` and fields as in the variable $SAVED_FIELDS.
The naming of course you can change directly in `sql/aws_instances.sql`

3) then run the script:

`zsh aws_ec2_instances_from_all_regions_to_db.zsh $DATABASE $TABLE_NAME`

4) Bonus step! If all works fine you can repeat with multiple environments.

`zsh run_script_for_multiple_profiles.zsh`

## Troubleshooting

you may get `Failed to parse JSON, or got false/null`
This means you probably don't have `jq` installed.


## run_script_for_multiple_profiles

Here is a script if you need to fetch the data from
multiple profiles. Just pass the names of your AWS profiles to the `profiles`
array in the `run_script_for_multiple_profiles.zsh` in line 4.

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
