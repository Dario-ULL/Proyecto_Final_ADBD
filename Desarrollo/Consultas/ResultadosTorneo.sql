SELECT E.ID_Equipo AS Equipo, T.Nombre AS Nombre_Torneo, T.Juego AS Juego_Torneo, R.Resultado, R.Victorias 
FROM Resultados_Torneo R
JOIN Equipos E ON R.ID_Equipo = E.ID_Equipo
JOIN Torneos T ON R.ID_Torneo = T.ID_Torneo;
