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

data = r"C:\javi\in_progress\veg_data_formating\quadrats\baseline\PennyAnderson_QuadratLocations_2014_2015_verifiedCB_25032021 (A3468021).xlsx"

df = pd.read_excel(data)
df.columns= df.columns.str.lower()
#print(df)

df["quadrat_id"] = df['site'].astype(str) + "__" + df["area"].astype(str) + "__" + df["quadrat"].astype(str) + "__" + df["date"].astype(str)  ## create unique quadrat ID
#print(df)

#df_1site = df[df['Site']=='Airds_Moss']   ## Lets play with just one site

## Create list of columns to generate quadrat info table

list_qinfo_columns = ['date','site','bog_type','area',
'nvc_community_paa_report','survey_restoration_stage',
'restoration_year','treatment','treatment_specific',
'paa_description', 'unique_id',
'quadrat','x','y','quadrat_size_m',
'avg_canopy_height_cm','dung_presence','brash_stumps',
'quadrat_id']

#### Generating quadrat info table ####
df_qinfo =  df.filter(list_qinfo_columns, axis=1)
df_qinfo.dropna(axis = 0, how = 'all', inplace = True)

#df_qinfo.to_sql('test_old_monitoring.quadrat_info', engine)

print(df_qinfo)

#### Generating quadrat veg table ####

## Create a list of columns to drop 

list_todrop_columns = ['date','site','bog_type','area',
'nvc_community_paa_report','survey_restoration_stage',
'restoration_year','treatment','treatment_specific',
'paa_description', 'unique_id',
'quadrat','x','y','quadrat_size_m',
'avg_canopy_height_cm','dung_presence','brash_stumps']

df_veg = df.drop(list_todrop_columns, axis=1)

#### Transponse

# Create a list of quadrats

list_of_quadrats = df_veg['quadrat_id'].unique().tolist()

#print(list_of_quadrats)

# Check if there are duplicated quadrats ID

a = [item for item, count in collections.Counter(list_of_quadrats).items() if count > 1]

if not a:
    print("There are NOT quadrats duplicated in: ", a)
else:
    print("There are quadrats duplicated in: ", a)
    exit(1)


# filter by quadrat ID. It will filter then row by row

# Create empty list to store all dataframe generated in the loop below

df_protocol_c = []

for q in list_of_quadrats:  # loop each quadrat ID, then transpose and create dataframe
    
    df_1quadrat = df_veg[df_veg['quadrat_id']==q]  # create dataframe where quadrat == item in unique quadrat list

    #print(df_1quadrat)

    df1_transposed = df_1quadrat.T # or df1.transpose()

    df1_transposed['quadrat_id'] = q
    df1_transposed = df1_transposed.drop('quadrat_id')
    df1_transposed = df1_transposed.set_axis(['percentage', 'quadrat_id'], axis=1, inplace=False)
    
    # SP name on index to column veg SP
    df1_transposed = df1_transposed.rename_axis('veg_sp').reset_index()

    # New index on index to column ID
    df1_transposed = df1_transposed.rename_axis('ID').reset_index()

    # reorder columns to have quadrat ID at the begining
    cols = df1_transposed.columns.tolist()
    cols = cols[-1:] + cols[:-1]
    df1_transposed = df1_transposed[cols]
    df1_transposed = df1_transposed.drop('ID', axis=1)
    #print(df1_transposed)

    df_protocol_c.append(df1_transposed)


df_protocol_c = pd.concat(df_protocol_c,ignore_index=True)  # concat all dataframes within the list
#print(df_protocol_c)


#df_protocol_c.to_sql('test_old_monitoring.quadrat_vegetation', engine)


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
  
#execute_values(conn, df_protocol_c, 'test_old_monitoring.bl_quadrat_vegetation')
execute_values(conn, df_qinfo, 'test_old_monitoring.bl_quadrat_info')


