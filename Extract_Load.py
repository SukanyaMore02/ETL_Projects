#import libraries
#!pip install kaggle
import kaggle

!kaggle datasets download ankitbansal06/retail-orders -f orders.csv

#read data from the file and handle null values
import pandas as pd
df = pd.read_csv('orders.csv',na_values=['Not Available','unknown'])
df['Ship Mode'].unique()


#rename columns names ..make them lower case and replace space with underscore
#df.rename(columns={'Order Id':'order_id', 'City':'city'})
#df.columns=df.columns.str.lower()
#df.columns=df.columns.str.replace(' ','_')
df.head(5)

#derive new columns discount , sale price and profit
#df['discount']=df['list_price']*df['discount_percent']*.01
#df['sale_price']= df['list_price']-df['discount']
df['profit']=df['sale_price']-df['cost_price']
df

#convert order date from object data type to datetime
df['order_date']=pd.to_datetime(df['order_date'],format="%Y-%m-%d")

#drop cost price list price and discount percent columns
df.drop(columns=['list_price','cost_price','discount_percent'],inplace=True)

#load the data into sql server using replace option
SERVER = 'DESKTOP-ESKG0PO\\SQLEXPRESS'
DATABASE = 'master'
DRIVER = 'ODBC+Driver+17+for+SQL+Server'
DATABASE_CONNECTION = f'mssql://{SERVER}/{DATABASE}?driver={DRIVER}'"
	
import sqlalchemy as sal
engine = sal.create_engine(DATABASE_CONNECTION)
conn = engine.connect()	

#load the data into sql server using append option
df.to_sql('orders', con=conn , index=False, if_exists = 'append')