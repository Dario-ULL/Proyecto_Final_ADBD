-- 1. Tabla: Equipos
CREATE TABLE Equipos (
    ID_Equipo SERIAL PRIMARY KEY,
    Juego TEXT NOT NULL
);

-- 2. Tabla: Jugadores
CREATE TABLE Jugadores (
    ID_Jugador SERIAL PRIMARY KEY,
    ID_Equipo INT,
    FOREIGN KEY (ID_Equipo) REFERENCES Equipos(ID_Equipo) ON DELETE RESTRICT,
    Primer_Apellido TEXT NOT NULL,
    Segundo_Apellido TEXT,
    Nombre TEXT NOT NULL,
    Nacionalidad TEXT NOT NULL,
    Fecha_Ingreso DATE NOT NULL CHECK (Fecha_Ingreso <= CURRENT_DATE),
    Apodo TEXT UNIQUE,
    Edad INT NOT NULL CHECK (Edad >= 18 AND Edad <= 100)
);

-- 3. Tabla: Torneos
CREATE TABLE Torneos (
    ID_Torneo SERIAL PRIMARY KEY,
    Juego TEXT NOT NULL,
    Nombre TEXT UNIQUE NOT NULL,
    Localizacion TEXT NOT NULL,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Final DATE NOT NULL CHECK (Fecha_Final >= Fecha_Inicio)
);

-- 4. Tabla: Patrocinadores
CREATE TABLE Patrocinadores (
    ID_Patrocinador SERIAL PRIMARY KEY,
    Nombre TEXT UNIQUE NOT NULL,
    Presupuesto DECIMAL(10, 2) NOT NULL CHECK (Presupuesto >= 0)
);

-- 5. Tabla: Administrativos
CREATE TABLE Administrativos (
    ID_Administrativo SERIAL PRIMARY KEY,
    ID_Equipo INT,
    FOREIGN KEY (ID_Equipo) REFERENCES Equipos(ID_Equipo) ON DELETE RESTRICT,
    Primer_Apellido TEXT NOT NULL,
    Segundo_Apellido TEXT,
    Nombre TEXT NOT NULL,
    Fecha_Ingreso DATE NOT NULL CHECK (Fecha_Ingreso <= CURRENT_DATE),
    Tipo TEXT NOT NULL CHECK (Tipo IN ('Administrador', 'Entrenador', 'Analista'))
);

-- 6. Tabla: Estadísticas de Jugadores
CREATE TABLE Estadisticas_Jugadores (
    ID_Jugador INT PRIMARY KEY,
    Estadistica TEXT NOT NULL,
    Valor DECIMAL(10, 2) NOT NULL CHECK (Valor >= 0),
    FOREIGN KEY (ID_Jugador) REFERENCES Jugadores(ID_Jugador) ON DELETE CASCADE
);

-- 7. Tabla: Resultados Torneo
CREATE TABLE Resultados_Torneo (
    ID_Equipo INT,
    ID_Torneo INT,
    Resultado TEXT NOT NULL,
    Partidos_Totales INT NOT NULL CHECK (Partidos_Totales >= 0),
    Victorias INT NOT NULL CHECK (Victorias >= 0 AND Victorias <= Partidos_Totales),
    PRIMARY KEY (ID_Equipo, ID_Torneo),
    FOREIGN KEY (ID_Equipo) REFERENCES Equipos(ID_Equipo) ON DELETE CASCADE,
    FOREIGN KEY (ID_Torneo) REFERENCES Torneos(ID_Torneo) ON DELETE CASCADE
);

-- Trigger para validar que el juego del equipo y torneo coincidan
CREATE OR REPLACE FUNCTION validar_juego_equipo_torneo()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Equipos E, Torneos T
        WHERE E.ID_Equipo = NEW.ID_Equipo AND T.ID_Torneo = NEW.ID_Torneo AND E.Juego = T.Juego
    ) THEN
        RAISE EXCEPTION 'El juego del equipo y del torneo no coinciden';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_juego
BEFORE INSERT OR UPDATE ON Resultados_Torneo
FOR EACH ROW EXECUTE FUNCTION validar_juego_equipo_torneo();

-- 8. Relación: Equipos - Patrocinadores
CREATE TABLE Equipo_Patrocinadores (
    ID_Equipo INT,
    ID_Patrocinador INT,
    PRIMARY KEY (ID_Equipo, ID_Patrocinador),
    FOREIGN KEY (ID_Equipo) REFERENCES Equipos(ID_Equipo) ON DELETE CASCADE,
    FOREIGN KEY (ID_Patrocinador) REFERENCES Patrocinadores(ID_Patrocinador) ON DELETE CASCADE
);

-- 9. Relación: Torneos - Jugadores
CREATE TABLE Torneo_Jugadores (
    ID_Torneo INT,
    ID_Jugador INT,
    PRIMARY KEY (ID_Torneo, ID_Jugador),
    FOREIGN KEY (ID_Torneo) REFERENCES Torneos(ID_Torneo) ON DELETE CASCADE,
    FOREIGN KEY (ID_Jugador) REFERENCES Jugadores(ID_Jugador) ON DELETE CASCADE
);

-- Restricción de Exclusión: Jugador y Administrativo
CREATE VIEW Exclusividad_Roles AS
SELECT 
    Jugadores.ID_Jugador AS ID_Conflicto
FROM 
    Jugadores
JOIN 
    Administrativos
ON 
    Jugadores.ID_Jugador = Administrativos.ID_Administrativo;
