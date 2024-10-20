
WITH tb_pontos_d as (

SELECT 


    idCustomer,

    -- CALCULANDO SALDO EM PONTOS

    sum(pointsTransaction) as saldoPointsD21,

    sum(CASE 
            WHEN dtTransaction >= DATE('{date}', '-14 day') 
            THEN pointsTransaction ELSE 0 
            END) AS saldoPointsD14,

    sum(CASE 
            WHEN dtTransaction >= DATE('{date}', '-7 day') 
            THEN pointsTransaction ELSE 0 
            END) AS saldoPointsD7,


   -- CALCULANDO PONTOS ACUMULADOS
    sum(CASE
            WHEN pointsTransaction > 0 THEN  pointsTransaction
            ELSE 0
        END ) as pointsAcumuladosD21,

    sum(CASE
            WHEN pointsTransaction > 0 
            AND dtTransaction >= date ('{date}', '-14 day')
            THEN  pointsTransaction
            ELSE 0
        END ) as pointsAcumuladosD14,

    sum(CASE
            WHEN pointsTransaction > 0 
            AND dtTransaction >= date ('{date}', '-7 day')
            THEN  pointsTransaction
            ELSE 0
        END ) as pointsAcumuladosD7,


   -- CALCULANDO PONTOS RESGATADOS
    sum(CASE
            WHEN pointsTransaction < 0 THEN  pointsTransaction
            ELSE 0
        END ) as pointsResgatadosD21,

    sum(CASE
            WHEN pointsTransaction < 0 
            AND dtTransaction >= date ('{date}', '-14 day')
            THEN  pointsTransaction
            ELSE 0
        END ) as pointsResgatadosD14,

    sum(CASE
            WHEN pointsTransaction < 0 
            AND dtTransaction >= date ('{date}', '-7 day')
            THEN  pointsTransaction
            ELSE 0
        END ) as pointsResgatadosD7


FROM transactions

WHERE dtTransaction < '{date}'
AND dtTransaction >=  DATE ('{date}',  '-21 DAY')

GROUP BY idCustomer),

tb_vida as (

-- CALCULANDO O SALDO CONSIDERANDO TODA A JORNADA (saldo de pontos na vida)
SELECT 

    t1.idCustomer,
    sum(t2.pointsTransaction) as saldoPoints,
    sum(CASE
            WHEN t2.pointsTransaction > 0 THEN  t2.pointsTransaction
            ELSE 0
        END ) as pointsAcumuladosVida,
    sum(CASE
            WHEN t2.pointsTransaction < 0 THEN  t2.pointsTransaction
            ELSE 0
        END ) as pointsResgatadosVida,

    CAST(max(julianday('{date}') - julianday(dtTransaction)) as INTEGER) + 1 AS diasVida    

FROM tb_pontos_d as T1

LEFT JOIN transactions as T2
ON t1.idCustomer = t2.idCustomer

WHERE t2.dtTransaction < '{date}' -- Garante dado d-1

GROUP BY t1.idCustomer),

tb_join as (

    -- JUNTANDO AS 2 QUERIES


    SELECT 

        t1.*,
        t2.saldoPoints,
        t2.pointsAcumuladosVida,
        t2.pointsResgatadosVida,
        1.0 * t2.pointsAcumuladosVida / t2.diasVida as pointsPorDia

    FROM 
        tb_pontos_d as t1
        
    LEFT JOIN tb_vida as t2
    ON t1.idCustomer = t2.idCustomer)

SELECT 
        '{date}' AS dtRef,
        *
FROM tb_join