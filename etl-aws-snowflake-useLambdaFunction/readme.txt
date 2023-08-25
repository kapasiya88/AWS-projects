This project is used to ingest the data from S3 to snowflake using snowpipe.
Whenever there is a new object in the source S3 bucket,a lambda will be invoked which will perform some transformation,put the new file into another s3 bucket and snowpipe will be trigered which will populate the file data into snowflake table.

1)	Create a source s3 bucket with default settings (snowflake-sourcedata).

2) Create a target s3 folder which will be target for lambda function and source for snowflake with 
default settings (snowflake-sourcedata/s3-target-data-demo/).

3) create lambda function (readcsv.py) which will read file from snowflake-sourcedata/s3-source-data-demo,
convert the data into pandas dataframe,remove the records having ID>30,and put the target file under 
snowflake-sourcedata/s3-target-data-demo/

This lambda function imports pandas library and hence a layer has to be created to deploy a package containing pandas,numpy and pytz modules.
Follow below link to create a layer in lambda function.

https://www.youtube.com/watch?v=1UDEp90S9h8

NOTE:Download pandas,numpy and pytz wheels which are compatible to your python version.

4) add trigger to lambda function on s3 bucket (snowflake-sourcedata/s3-source-data-demo) for event type (All object create events).

5) create appropriate IAM roles to attach to lambda function having access to
s3 bucket
snsnotification
cloudwatch

6) create IAM role to provide access to snowflake to AWS.
Role name: mysnowflakerole-kajal
Refer mysnowflakerole-kajal.json

7) setup snowflake infrastructure:
refer snowflake_commands.sql

8)  update the ARN and external id from the integration object created in above step to the IAM role created in step 6.

a) DESC INTEGRATION S3_Snowflake;

b) edit mysnowflakerole-kajal -> trust relationships

copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from 8(a) and paste to 8(b)

9) copy the notification channel from below command for your pipe.
show pipes;

paste to bucket which is source to snowflake:
snowflake-sourcedata -> properties -> event_notifications

a) Event name
call_snowflake_pipe

b) prefix
s3-target-data-demo/

c) event types:
all object create events

d) destination:
SQS queue
enter SQS queue ARN (copy it from show pipes)
