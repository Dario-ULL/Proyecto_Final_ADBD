import os
import time
import psycopg2
from psycopg2 import sql

db_host = os.getenv("POSTGRES_HOST", "localhost")
db_name = os.getenv("POSTGRES_DB", "tete")
db_user = os.getenv("POSTGRES_USER", "postgres")
db_password = os.getenv("POSTGRES_PASSWORD", "qYbpTIC7")

# Intentar conectar hasta que la base de datos esté lista
while True:
    try:
        # Conexión a la base de datos
        conn = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=db_password
        )
        break 
    except psycopg2.OperationalError:
        print("Base de datos no disponible, reintentando en 5 segundos...")
        time.sleep(5)  # Esperar antes de reintentar la conexión


# Open a cursor to perform database operations
cur = conn.cursor()

cur.execute('INSERT INTO Equipos (juego) VALUES (%s)', ('League of Legends',))
cur.execute('INSERT INTO Equipos (juego) VALUES (%s)', ('CS GO 2',))
cur.execute('INSERT INTO Equipos (juego) VALUES (%s)', ('Valorant',))

conn.commit()

cur.close()
conn.close()