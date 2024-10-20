## Esse arquivo irá executar a consulta e armazenar as feature store

# %%

 ## Importando as bibliotecas
import argparse
import datetime

import pandas as pd
import sqlalchemy

from sqlalchemy import exc
from tqdm import tqdm

## Função para exibir as queries em formato de texto

def import_query (path):
    #with open (path, 'r') as open_file:
    with open(path, 'r',  encoding="utf-8") as open_file:
        return open_file.read()

## Função que gera lista de datas
def date_range (start , stop):
    dt_start = datetime.datetime.strptime(start, '%Y-%m-%d')
    dt_stop = datetime.datetime.strptime(stop, '%Y-%m-%d')
    dates = []
    while dt_start <= dt_stop:
        dates.append(dt_start.strftime('%Y-%m-%d'))
        dt_start += datetime.timedelta(days=1)
    return dates

## Função que faz ingestão dos dados

def ingest_date (query , table, dt):

    # substituição de {date} por uma data
    query_fmt = query.format(date = dt)

    ## Criando Dataframe a partir do script SQL
    df = pd.read_sql(query_fmt , origin_engine)

    ## Deleta os dados de referência para garantir integridade
    with target_engine.connect() as con:
        try: 
            state = f'DELETE FROM {table} WHERE dtRef = "{dt}";'
            con.execute(sqlalchemy.text(state))
            con.commit()
        except exc.OperationalError as err:
            print('Tabela inexistente... Criando!!')

    ## Salvando Dataframe em um banco Sqlite

    df.to_sql(table, target_engine , index=False , if_exists= 'append')

# %%

now = datetime.datetime.now().strftime("%Y-%m-%d")

parser = argparse.ArgumentParser()
parser.add_argument("--feature_store", "-f", help = "Nome da feature store", type=str)
parser.add_argument("--start", "-s", help="Data de início", default=now)
parser.add_argument("--stop", "-p", help= "Data de Fim", default=now)

args = parser.parse_args()

## Criando as conexões com o databases

origin_engine = sqlalchemy.create_engine("sqlite:///../../data/database.db")

target_engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

## importe da query
query = import_query  (f"{args.feature_store}.sql")

dates = date_range (args.start, args.stop)

for i in tqdm(dates):
    ingest_date(query, args.feature_store, i)

# %%


# %%

# %%

# %%
# %%
