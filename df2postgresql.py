import collections
from sqlalchemy import create_engine
import psycopg2
import numpy as np
import psycopg2.extras as extras
from credentials import *

import pandas as pd

#pd.set_option('display.max_rows', None)
#pd.set_option('display.max_columns', None)

## Create Postgres Connection

conn = psycopg2.connect(database=database, user=user, password=password, host=host, port=port)

data = r"C:\javi\in_progress\veg_data_formating\quadrats\baseline_survey_dates.xlsx"

df = pd.read_excel(data)
df.columns= df.columns.str.lower()
print(df)



def execute_values(conn, df, table):
  
    tuples = [tuple(x) for x in df.to_numpy()]
  
    cols = ','.join(list(df.columns))
    # SQL query to execute
    query = "INSERT INTO %s(%s) VALUES %%s" % (table, cols)
    cursor = conn.cursor()
    try:
        extras.execute_values(cursor, query, tuples)
        conn.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        print("Error: %s" % error)
        conn.rollback()
        cursor.close()
        return 1
    print("the dataframe is inserted")
    cursor.close()
  
execute_values(conn, df, 'test_old_monitoring.bl_survey_dates')


