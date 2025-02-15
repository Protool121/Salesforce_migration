from Connection import sessions, Salesforce
import pandas as pd
import io
from tabulate import tabulate

class Salesrunner():
    resource = sessions.resource(service_name='s3')
    client   = sessions.client  (service_name='s3')

    
    def __init__(self,BucketName, Key,FileName):
        self.BucketName = BucketName
        self.Key        = Key
        self.FileName   = FileName

    def ReadFileS3(self):
        try:
            response = Salesrunner.client.get_object(Bucket = self.BucketName, Key = f"{self.Key}{self.FileName}")
            data = response['Body'].read().decode('utf-8')
            df = pd.read_csv(io.StringIO(data))
            
            return df   

        except Exception as e:
            print(f"{self.BucketName} not found",e)

    def SalesforceQuery(self):
        Opp = Salesforce.query('select id, name , Amount, type from opportunity')['records']
        df = pd.DataFrame(Opp)
        df.drop('attributes', axis=1,inplace=True)
        df = pd.DataFrame(df).to_records
        
        # return df
        
        
        # results = Salesforce.Opportunity.update(df, batch=10000, use_serial=True)
        results = Salesforce.Opportunity.update(df, use_serial=True)
        print(results)
        # SalesforceSalesforce.bulk2.Opportunity.update(df,batch_size=10000,use_serial=True)
        
        FileName = io.BytesIO()
        df.to_csv(FileName, index=False)
        try:
            LoadFile = Salesrunner.resource.Object(self.BucketName, f"{self.Key}{self.FileName}").put(Body=FileName.getvalue())
            return LoadFile
        
        except Exception as e:
            print(f"{self.BucketName} not found",e)
            
    def SalesforceDataLoad(self):
        DataToLoad = df
        print(DataToLoad)
        
        External = f"SAP_{self}UUIDExlu__c"
        
        SalesforceLoading = f"Salesforce.bulk{self.FileName}"
        Data = eval(SalesforceLoading)(df, External, batch_Size =200, use_serialize = False)
        print(Data)
        # ReadFile = Salesrunner(self.BucketName, self.Key)
        
        
if __name__ == "__main__":
    

    Bucket = Salesrunner(f'salesrunner','data/','Opportunities')
    # ReadFile = Bucket.ReadFileS3()
    # # print(ReadFile)
    
    # LoadFileToS3= Salesrunner('salesrunner','data/','Opportunities.csv')
    # Reload = LoadFileToS3.SalesforceQuery()
    # print('Salesrunner Complete')
    
    Data = Bucket.SalesforceQuery('Opportunity')
    
    print(Data)
    

    