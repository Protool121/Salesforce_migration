import pandas as pd 
from sqlalchemy import create_engine, text
import boto3
from simple_salesforce import Salesforce


# Login to AWS via profile or Access key and Secret Access Key
sessions = boto3.Session(profile_name           ="default", 
                         region_name            ="eu-west-2", 
                         aws_secret_access_key  ="***********", 
                         access_key             ="***********",)

# Salesforce connections
Salesforce = Salesforce(username       = '********',
                        password       = '********',
                        security_token = '********',
                        )
# Postgres database connection logging.
def databaseConnection():
        
    username ="******",
    password ="******",
    host     ="******",
    port     ="******",
    database ="******",
    connection_string = f"postgresql://{username}:{password}@{host}:{port}/{database}",
    engine = create_engine(connection_string),
    connection = engine.connect(),
    return connection
