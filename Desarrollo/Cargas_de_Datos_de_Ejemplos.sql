-- 1. Insertar datos en la tabla Equipos
INSERT INTO Equipos (Juego)
VALUES 
('League of Legends'),
('Dota 2'),
('League of Legends');

-- 2. Insertar datos en la tabla Jugadores
INSERT INTO Jugadores (ID_Equipo, Primer_Apellido, Segundo_Apellido, Nombre, Nacionalidad, Fecha_Ingreso, Apodo, Edad)
VALUES 
(1, 'Gómez', 'López', 'Juan', 'México', '2023-01-10', 'ElRayo', 25),
(2, 'Martínez', 'Pérez', 'Luis', 'España', '2022-05-15', 'Shadow', 30),
(3, 'Fernández', 'Ruiz', 'Ana', 'Argentina', '2021-03-20', 'Stellar', 22);

-- 3. Insertar datos en la tabla Torneos
INSERT INTO Torneos (Juego, Nombre, Localizacion, Fecha_Inicio, Fecha_Final)
VALUES 
('League of Legends', 'Copa Mundial LoL 2024', 'Seúl', '2024-06-01', '2024-07-01'),
('Dota 2', 'The International 2024', 'Seattle', '2024-08-15', '2024-08-30'),
('League of Legends', 'Mid Season Invitational 2024', 'Seattle', '2024-08-15', '2024-08-30');

-- 4. Insertar datos en la tabla Patrocinadores
INSERT INTO Patrocinadores (Nombre, Presupuesto)
VALUES 
('Titsa', 100000.00),
('CCC', 50000.00),
('Hiperdino', 75000.00);

-- 5. Insertar datos en la tabla Administrativos
INSERT INTO Administrativos (ID_Equipo, Primer_Apellido, Segundo_Apellido, Nombre, Fecha_Ingreso, Tipo)
VALUES 
(1, 'Sánchez', 'Gómez', 'Carlos', '2021-02-01', 'Entrenador'),
(1, 'Lopez', 'Martín', 'María', '2022-04-15', 'Administrador'),
(1, 'Torres', 'Vega', 'Elena', '2023-01-20', 'Analista');

-- 6. Insertar datos en la tabla Estadísticas de Jugadores
INSERT INTO Estadisticas_Jugadores (ID_Jugador, Estadistica, Valor)
VALUES 
(1, 'Victorias', 45),
(2, 'Porcentaje de Victorias', 78.5),
(3, 'Partidos Totales', 120);

-- 7. Insertar datos en la tabla Resultados_Torneo
INSERT INTO Resultados_Torneo (ID_Equipo, ID_Torneo, Resultado, Partidos_Totales, Victorias)
VALUES 
(1, 1, 'Semifinalista', 10, 7),
(2, 2, 'Campeón', 12, 12),
(1, 3, 'Campeón', 12, 12);

-- 8. Insertar datos en la relación Equipo_Patrocinadores
INSERT INTO Equipo_Patrocinadores (ID_Equipo, ID_Patrocinador)
VALUES 
(1, 1),
(2, 2),
(3, 3);

-- 9. Insertar datos en la relación Torneo_Jugadores
INSERT INTO Torneo_Jugadores (ID_Torneo, ID_Jugador)
VALUES 
(1, 1),
(2, 2);
