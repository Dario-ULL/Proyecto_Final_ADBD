SELECT A.Nombre AS Nombre_Administrativo, A.Tipo, E.Nombre AS Nombre_Equipo 
FROM Administrativos A
JOIN Equipo_Administrativos EA ON A.ID_Administrativo = EA.ID_Administrativo
JOIN Equipos E ON EA.ID_Equipo = E.ID_Equipo;
