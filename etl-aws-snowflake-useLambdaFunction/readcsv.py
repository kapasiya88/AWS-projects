import pandas as pd
import boto3
import io
from io import StringIO

service_name = 's3'
region_name = 'eu-west-2'

def lambda_handler(event, context):
    s3_file_key = event['Records'][0]['s3']['object']['key']
    in_bucket = 's3-source-data-demo'
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket=in_bucket, Key=s3_file_key)
    initial_df = pd.read_csv(io.BytesIO(obj['Body'].read()))
    
    s3_resource = boto3.resource(
        service_name=service_name,
        region_name=region_name
    )
    
    out_bucket='snowflake-sourcedata'
    s3_file_key_out='s3-target-data-demo/'+s3_file_key
    df = initial_df[(initial_df.ID > 30)]
    csv_buffer = StringIO()
    df.to_csv(csv_buffer,index=False)
    s3_resource.Object(out_bucket, s3_file_key_out).put(Body=csv_buffer.getvalue())