from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
import boto3
import os
import io
from datetime import date, datetime
import pandas as pd
from sqlalchemy import create_engine

cur_month = str(datetime.now().date().month)
cur_year = str(datetime.now().date().year)
parquet_name = f"bandcamp_sales_{cur_year}_{cur_month}.parquet"

aws_access_key_id = Variable.get('aws_access_key_id')
aws_secret_access_key = Variable.get('aws_secret_access_key')
bucket_name = Variable.get('bucket_name')
pg_conn_string = Variable.get('pg_conn_string')

session = boto3.session.Session(aws_access_key_id=aws_access_key_id,
    aws_secret_access_key= aws_secret_access_key)

s3 = session.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net')



file_name = "/data/data.csv"

COLS_USED = ['utc_date', 'country', 'slug_type', 'item_price', 
             'item_description', 'amount_paid', 'artist_name',
			 'currency', 'album_title', 'amount_paid_usd']


def data_transformation(df):	
	cols_not_used = [col for col in df.columns if col not in COLS_USED]
	df.drop(cols_not_used, inplace=True, axis=1)
	df['utc_datetime'] = pd.to_datetime(df['utc_date'],unit='s')
	df['utc_date'] = df['utc_datetime'].astype(str).str[:10]
	df_obj = df.select_dtypes(['object'])
	df[df_obj.columns] = df_obj.apply(lambda x: x.str.strip())
	return df

def get_data():
	df = pd.read_csv(file_name)
	df.to_parquet(parquet_name)

def upload_to_s3():
	s3.upload_file(parquet_name, bucket_name, parquet_name)
	os.remove(parquet_name)

def from_s3_to_dwh():
	engine = create_engine(pg_conn_string).execution_options(autocommit=True)
	obj = s3.get_object(Bucket=bucket_name, Key=parquet_name)
	df = pd.read_parquet(io.BytesIO(obj['Body'].read()))
	df = data_transformation(df)
	df.to_sql('bandcamp_sales', schema="marts", con=engine, if_exists="append", index=False, 
				chunksize = 1000, method='multi')


with DAG('project_dag', description='project dag', 
	schedule_interval='@once', start_date=datetime(2020, 1, 1),
	catchup=False) as dag:
	start_dag = DummyOperator(task_id='start_dag', retries=3)
	get_data = PythonOperator(task_id='get_data', python_callable=get_data)
	upload_to_s3 = PythonOperator(task_id='upload_to_s3', python_callable=upload_to_s3)
	from_s3_to_dwh = PythonOperator(task_id='from_s3_to_dwh', python_callable=from_s3_to_dwh)
	finish_dag = DummyOperator(task_id='finish_dag', retries=3)

start_dag >> get_data >> upload_to_s3 >> from_s3_to_dwh >> finish_dag

