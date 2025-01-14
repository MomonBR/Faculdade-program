-- PROVA 2 DE BANCOS DE DADOS, SELECT AVANÇADO

-- 1 A - Resultado por Equipes nas últimas 5 temporadas (2024 inclusive)
SELECT RACES.YEAR AS ANO, CONSTRUCTORS.name AS EQUIPE, SUM(RESULTS.POINTS) AS PONTOS
	FROM RESULTS
	JOIN CONSTRUCTORS ON CONSTRUCTORS.CONSTRUCTORID = RESULTS.CONSTRUCTORID
	JOIN RACES ON RACES.RACEID = RESULTS.RACEID
	WHERE RACES.YEAR > 2019
	GROUP BY CUBE(ANO, EQUIPE) 
	ORDER BY ANO, PONTOS DESC;


-- 2 B - Classificação da temporada 2024 (12 etapas)
	
SELECT DRIVERS.SURNAME AS PILOTO,
		SUM(CASE WHEN RACES.ROUND = 1 THEN RESULTS.POINTS ELSE 0 END) AS R1,
		SUM(CASE WHEN RACES.ROUND = 2 THEN RESULTS.POINTS ELSE 0 END) AS R2,
		SUM(CASE WHEN RACES.ROUND = 3 THEN RESULTS.POINTS ELSE 0 END) AS R3,
		SUM(CASE WHEN RACES.ROUND = 4 THEN RESULTS.POINTS ELSE 0 END) AS R4,
		SUM(CASE WHEN RACES.ROUND = 5 THEN RESULTS.POINTS ELSE 0 END) AS R5,
		SUM(CASE WHEN RACES.ROUND = 6 THEN RESULTS.POINTS ELSE 0 END) AS R6,
		SUM(CASE WHEN RACES.ROUND = 7 THEN RESULTS.POINTS ELSE 0 END) AS R7,
		SUM(CASE WHEN RACES.ROUND = 8 THEN RESULTS.POINTS ELSE 0 END) AS R8,
		SUM(CASE WHEN RACES.ROUND = 9 THEN RESULTS.POINTS ELSE 0 END) AS R9,
		SUM(CASE WHEN RACES.ROUND = 10 THEN RESULTS.POINTS ELSE 0 END) AS R10,
		SUM(CASE WHEN RACES.ROUND = 11 THEN RESULTS.POINTS ELSE 0 END) AS R11,
		SUM(CASE WHEN RACES.ROUND = 12 THEN RESULTS.POINTS ELSE 0 END) AS R12,
		SUM(RESULTS.POINTS) AS TOTAL_PONTOS
	FROM RESULTS
	JOIN RACES ON RACES.RACEID = RESULTS.RACEID
	JOIN DRIVERS ON DRIVERS.DRIVERID = RESULTS.DRIVERID
	WHERE RACES.YEAR = 2024
	GROUP BY 1 
	ORDER BY 1;


-- 3 C - Classificação da média de pontos por corrida dos pilotos(últimas 5 temporadas)

WITH PONTOS_CORRIDAS AS (
	SELECT DRIVERS.SURNAME AS PILOTO, SUM(RESULTS.POINTS) AS SOMA, COUNT(*) AS LINHAS
	FROM RESULTS
	JOIN RACES ON RACES.RACEID = RESULTS.RACEID
	JOIN DRIVERS ON DRIVERS.DRIVERID = RESULTS.DRIVERID
	WHERE RACES.YEAR > 2019
	GROUP BY 1 
	ORDER BY 1
),
	MEDIASPILOTOS AS (
	SELECT PILOTO, ROUND((SOMA * 1.0 / LINHAS), 2) AS MEDIA
	FROM PONTOS_CORRIDAS
)
SELECT PILOTO, MEDIA,
		CASE 
			WHEN MEDIA > ((SELECT AVG(MEDIA) FROM MEDIASPILOTOS) + 
							(1.96 * (SELECT STDDEV(MEDIA) FROM MEDIASPILOTOS) /
							SQRT((SELECT COUNT(1) FROM MEDIASPILOTOS))))
			THEN 'ACIMA' 
			WHEN MEDIA < ((SELECT AVG(MEDIA) FROM MEDIASPILOTOS) - 
							(1.96 * (SELECT STDDEV(MEDIA) FROM MEDIASPILOTOS) /
							SQRT((SELECT COUNT(1) FROM MEDIASPILOTOS))))
			THEN 'ABAIXO' ELSE 'MEDIA' END AS CLASSE,
		CASE 
			WHEN MEDIA  > ((SELECT PERCENTILE_DISC(0.75)
							WITHIN GROUP (ORDER BY MEDIA) FROM MEDIASPILOTOS) +
							((SELECT PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY MEDIA) FROM MEDIASPILOTOS) -
							(SELECT PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY MEDIA) FROM MEDIASPILOTOS)) * 1.5)
			THEN 'OUTLIER' ELSE 'NORMAL' END AS OUTLIER_MAXIMO
	FROM MEDIASPILOTOS
	ORDER BY MEDIA DESC;

	
-- 4 D - Pontuação acumulada de cada piloto (12 etapas da temporada atual)

SELECT DRIVERS.SURNAME AS PILOTO,
		SUM(CASE WHEN RACES.ROUND = 1 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R1,
		SUM(CASE WHEN RACES.ROUND = 2 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R2,
		SUM(CASE WHEN RACES.ROUND = 3 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R3,
		SUM(CASE WHEN RACES.ROUND = 4 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R4,
		SUM(CASE WHEN RACES.ROUND = 5 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R5,
		SUM(CASE WHEN RACES.ROUND = 6 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R6,
		SUM(CASE WHEN RACES.ROUND = 7 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R7,
		SUM(CASE WHEN RACES.ROUND = 8 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R8,
		SUM(CASE WHEN RACES.ROUND = 9 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R9,
		SUM(CASE WHEN RACES.ROUND = 10 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R10,
		SUM(CASE WHEN RACES.ROUND = 11 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R11,
		SUM(CASE WHEN RACES.ROUND = 12 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS R12,
		SUM(CASE WHEN RACES.ROUND = 12 THEN DRIVER_STANDINGS.POINTS ELSE 0 END) AS VALOR_ACUMULADO
	FROM DRIVER_STANDINGS
	JOIN RACES ON RACES.RACEID = DRIVER_STANDINGS.RACEID
	JOIN DRIVERS ON DRIVERS.DRIVERID = DRIVER_STANDINGS.DRIVERID
	WHERE RACES.YEAR = 2024
	GROUP BY PILOTO ORDER BY VALOR_ACUMULADO DESC;