SELECT Nacionalidad, COUNT(*) AS Total_Jugadores 
FROM Jugadores
GROUP BY Nacionalidad
ORDER BY Total_Jugadores DESC;