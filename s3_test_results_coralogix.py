#!/usr/bin/env python3

# this script uploads the local "stress_test_logs.txt" and "stress_test_error_logs.txt" as objects within the cntf-open5gs-test-results S3 bucket.

import os
import pathlib
from glob import glob
import boto3
import botocore.exceptions

BASE_DIR = pathlib.Path(__file__).parent.resolve()
FILE_DIR = os.path.join(BASE_DIR)

BUCKET_NAME = 'cntf-open5gs-test-results'
AWS_REGION = 'us-east-1'

def upload_file(file_name, bucket, object_name):
    s3_resource = boto3.resource('s3', region_name=AWS_REGION)

    if object_name is None:
        object_name = file_name

    s3_client = s3_resource.meta.client

    # Check if the object already exists in the bucket
    try:
        s3_client.head_object(Bucket=bucket, Key=object_name)
        print(f"Object '{object_name}' already exists in bucket '{bucket}'. Skipping upload.")
        return
    except botocore.exceptions.ClientError as e:
        # Object does not exist, proceed with upload
        if e.response['Error']['Code'] == '404':
            s3_client.upload_file(file_name, bucket, object_name)
        else:
            # Other error occurred
            raise

if __name__ == '__main__':
    file_name = os.path.join(FILE_DIR, 'time_to_populate_database.txt')
    upload_file(file_name=file_name, bucket=BUCKET_NAME, object_name='time_to_populate_database.txt') # create an object called 'time_to_populate_database.txt' in s3 bucket 'cntf-open5gs-test-results'


