--create a snowflake table
create or replace table emp_data 
(firstname varchar2(100) , lastname varchar2(100),
id number(3) , ip varchar2(20));

--create a csv file format
create or replace file format csv_format
  type = csv field_delimiter = ',' skip_header = 1
  field_optionally_enclosed_by = '"'
  null_if = ('NULL', 'null') 
  empty_field_as_null = true;


--create a STORAGE INTEGRATION
CREATE or replace STORAGE INTEGRATION S3_Snowflake 
	TYPE = EXTERNAL_STAGE 
	STORAGE_PROVIDER = S3
	ENABLED = TRUE 
	STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::211678918935:role/mysnowflakerole-kajal'
	STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-sourcedata');

--get the properties of STORAGE INTEGRATION
DESC INTEGRATION S3_Snowflake; 


--create external stage for a particular folder from S3.One stage can refer to one file format.
create or replace stage emp_data_stage 
url="s3://snowflake-sourcedata/s3-target-data-demo/" 
storage_integration = S3_Snowflake
file_format = csv_format;


--shows all stages.
show  stages;

--create a pipe to auto ingest data from external stage to snowflake table.It is particular to one file format.
create or replace pipe S3_Snowflake 
auto_ingest=true
as 
copy into emp_data
from @emp_data_stage
file_format = (FORMAT_NAME=csv_format);


--shows the pipes
show pipes;


--check the copy history based on input time.
select * from table(information_schema.copy_history(TABLE_NAME=>'emp_data', START_TIME=> DATEADD(hours, -1, CURRENT_TIMESTAMP())));

--select the columns directly from external stage.
select t.$1,t.$2,t.$3,t.$4 from @emp_data_stage t;

--list all the files present in an external stage.
list @emp_data_stage;