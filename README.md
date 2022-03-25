This file contains instructions how to run the project.

## 1. Create infrastructure in Yandex Cloud using Terraform.

There are two files in a repository - main.tf and varibles.tf

**main.tf** is a configuration file containing instructions of creation a bucket in the S3 storage and the PostgreSQL cluster

**variables.tf** is a file containing description of variables used in the configuration

You need to create a secret file for sensitive data which will be used in creation of infrastructure. For example, this file can be named as `secret.tfvars`.

The file should contain the next information:

`db_name` - name of a database used for the project

`db_username` - name of database user

`db_password` - password of a database user

`yandex_cloud_token` - yandex cloud token

`yandex_cloud_id` - yandex cloud id

`yandex_cloud_folder_id` - yandex cloud folder id

`yandex_cloud_access_key` - yandex cloud access key

`yandex_cloud_secret_key` - yandex cloud secret key

`yandex_cloud_network_id` - yandex cloud network id (could also be created automatically)

To create infrastructure run next commands:

 - `terraform init`

 - `terraform apply -var-file="secret.tfvars"`

 - `terraform destroy -var-file="secret.tfvars"` - when the project will be finished it deletes all project infrastructure created

 **Please, be sure, the project DWH database has public access. It can be checked in its network settings**

 ## 2. Creation of a data mart table in DWH

 To do so, connect to the database via any available client and run the `DWH_creation.sql` script from the `sql` folder.

 ## 3. Deploying airlow with data processing DAG and metabase for making a dashboard.

 To do this you can just run `docker-compose up`.

The aiflow UI should be available at http://127.0.0.1:8080/

It is assumed that you have a folder called `data` which has a csv file with data to be processed and analysed.

 After running airflow, you need to add variables with the next information:

- aws_access_key_id 
- aws_secret_access_key 
- bucket_name 
- pg_conn_string (postgresql://<user name>:<user password>@<host>:<port>/<project name>)

Then, run `project_dag` to perform the entire ELT process. 
The `schedule_interval` of a dag is set to `@once` since there is no more data for the given project. However, `schedule_interval` can be changed to another value if there will be a source of similar data. As a result, a batch processing can be done on a reular basis.

## 4. Make a dashboard

The metabase UI should be available http://127.0.0.1:3000/
Log in into it and start working.

Connect to the DWH following instructions.




 
