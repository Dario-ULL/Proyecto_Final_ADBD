import os
import psycopg2
from flask import Flask, render_template, request, url_for, redirect

# Configuración de conexión a la base de datos
db_host = os.getenv("POSTGRES_HOST", "localhost")
db_name = os.getenv("POSTGRES_DB", "tete")
db_user = os.getenv("POSTGRES_USER", "postgres")
db_password = os.getenv("POSTGRES_PASSWORD", "qYbpTIC7")

app = Flask(__name__)

# Función para obtener la conexión a la base de datos
def get_db_connection():
    conn = psycopg2.connect(
        host=db_host,
        database=db_name,
        user=db_user,
        password=db_password
    )
    return conn

# Ruta principal: lista todos los equipos
@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT * FROM Equipos ORDER BY ID_Equipo;')
        equipos = cur.fetchall()
    except Exception as e:
        error_message = f'Error al conectar con la base de datos: {str(e)}'
        return render_template('error.html', error_message=error_message)
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
    return render_template('index.html', equipos=equipos)

# Ruta para mostrar páginas estáticas
@app.route('/<page_name>.html')
def static_page(page_name):
    return render_template(f'{page_name}.html')

# Ruta para crear un nuevo equipo
@app.route('/create/', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        try:
            juego = request.form['juego']
            if not juego:
                raise ValueError("El campo 'juego' no puede estar vacío.")

            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('INSERT INTO Equipos (Juego) VALUES (%s)', (juego,))
            conn.commit()
        except Exception as e:
            error_message = f'Error al insertar los datos: {str(e)}'
            return render_template('error.html', error_message=error_message)
        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals():
                conn.close()
        return redirect(url_for('index'))

    return render_template('create.html')

# Ruta para eliminar un equipo
@app.route('/delete/', methods=['GET', 'POST'])
def delete():
    if request.method == 'POST':
        equipo_id = request.form.get('ID_Equipo')
        try:
            if not equipo_id:
                raise ValueError("El campo 'ID_Equipo' no puede estar vacío.")

            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('DELETE FROM Equipos WHERE ID_Equipo = %s', (equipo_id,))
            
            # Verifica si se eliminó algún registro
            if cur.rowcount == 0:
                return render_template('error.html', error_message=f'El equipo con ID {equipo_id} no existe.')

            conn.commit()
        except Exception as e:
            error_message = f'Error al eliminar el equipo: {str(e)}'
            return render_template('error.html', error_message=error_message)
        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals():
                conn.close()
        return redirect(url_for('index'))

    return render_template('delete.html')

# Ruta para actualizar un equipo
@app.route('/update/<int:equipo_id>', methods=['GET', 'POST'])
def update(equipo_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        if request.method == 'POST':
            juego = request.form['juego']
            if not juego:
                raise ValueError("El campo 'juego' no puede estar vacío.")

            cur.execute('UPDATE Equipos SET Juego = %s WHERE ID_Equipo = %s', (juego, equipo_id))
            conn.commit()
            return redirect(url_for('index'))

        # Obtén los datos del equipo
        cur.execute('SELECT * FROM Equipos WHERE id_equipo = %s', (equipo_id,))
        equipo = cur.fetchone()

        if equipo is None:
            return render_template('error.html', error_message=f'El equipo con ID {equipo_id} no existe.')
    except Exception as e:
        error_message = f'Error al actualizar el equipo: {str(e)}'
        return render_template('error.html', error_message=error_message)
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()

    return render_template('update.html', equipo=equipo)

@app.route('/resultados/<int:equipo_id>', methods=['GET'])
def resultados(equipo_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT * FROM resultados_torneo WHERE id_equipo = %s', (equipo_id,))
        resultados = cur.fetchall()
    except Exception as e:
        error_message = f'Error al obtener los resultados del equipo: {str(e)}'
        return render_template('error.html', error_message=error_message)
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
    
    return render_template('resultados.html', resultados=resultados)

@app.route('/integrantes/<int:equipo_id>', methods=['GET'])
def integrantes(equipo_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Consultar jugadores del equipo
        cur.execute(''' 
            SELECT j.nombre, j.primer_apellido, j.segundo_apellido, 'Jugador' AS tipo, j.apodo
            FROM jugadores j 
            WHERE j.id_equipo = %s;
        ''', (equipo_id,))
        jugadores = cur.fetchall()

        # Consultar administrativos del equipo
        cur.execute(''' 
            SELECT a.nombre, a.primer_apellido, a.segundo_apellido, a.tipo 
            FROM administrativos a 
            WHERE a.id_equipo = %s;
        ''', (equipo_id,))
        administrativos = cur.fetchall()

        # Combinar ambos resultados
        integrantes = administrativos + jugadores

    except Exception as e:
        error_message = f'Error al obtener los integrantes del equipo: {str(e)}'
        return render_template('error.html', error_message=error_message)
    
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()

    return render_template('integrantes.html', integrantes=integrantes)

@app.route('/patrocinadores/<int:equipo_id>', methods=['GET'])
def patrocinadores(equipo_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('''
            SELECT p.nombre, p.presupuesto
            FROM patrocinadores p
            INNER JOIN equipo_patrocinadores ep ON p.id_patrocinador = ep.id_patrocinador
            WHERE ep.id_equipo = %s;
        ''', (equipo_id,))
        patrocinadores = cur.fetchall()
    except Exception as e:
        error_message = f'Error al obtener los patrocinadores del equipo: {str(e)}'
        return render_template('error.html', error_message=error_message)
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
    
    return render_template('patrocinadores.html', patrocinadores=patrocinadores)

@app.route('/agregar_jugador/<int:equipo_id>', methods=['GET', 'POST'])
def agregar_jugador(equipo_id):
    if request.method == 'POST':
        # Obtener datos del formulario
        nombre = request.form['nombre']
        primer_apellido = request.form['primer_apellido']
        segundo_apellido = request.form['segundo_apellido']
        edad = request.form['edad']
        nacionalidad = request.form['nacionalidad']
        apodo = request.form['apodo']  # Agregar apodo desde el formulario
        
        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()

            # Insertar el nuevo jugador
            cur.execute(''' 
                INSERT INTO jugadores (id_equipo, nombre, primer_apellido, segundo_apellido, edad, nacionalidad, fecha_ingreso, apodo)
                VALUES (%s, %s, %s, %s, %s, %s, CURRENT_DATE, %s);
            ''', (equipo_id, nombre, primer_apellido, segundo_apellido, edad, nacionalidad, apodo))

            # Confirmar cambios
            conn.commit()

        except Exception as e:
            error_message = f'Error al agregar el jugador: {str(e)}'
            return render_template('error.html', error_message=error_message)

        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals():
                conn.close()

        # Redirigir al listado de integrantes
        return redirect(url_for('integrantes', equipo_id=equipo_id))

    return render_template('agregar_jugador.html', equipo_id=equipo_id)

if __name__ == '__main__':
    app.run(debug=True)