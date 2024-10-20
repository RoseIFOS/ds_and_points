WITH tb_transactions_hour AS (

SELECT
    idCustomer,
    pointsTransaction,
    CAST (STRFTIME('%H', -- Extrai hora da data transformada
        DATETIME(dtTransaction, '-3 hour')) AS INTEGER) AS hour -- transforma utc 0 para utc -3 (Brasil)

FROM transactions
WHERE dtTransaction < '{date}'
AND dtTransaction >= DATE ('{date}', '-21 day')

),

tb_share AS (

SELECT 

    idCustomer,
    SUM(CASE WHEN hour >= 8 AND hour < 12 THEN ABS(pointsTransaction) ELSE 0 END ) AS qtdPointsManha,
    SUM(CASE WHEN hour >= 12 AND hour < 18 THEN ABS(pointsTransaction) ELSE 0 END ) AS qtdPointsTarde,
    SUM(CASE WHEN hour >= 18 AND hour <= 23 THEN ABS(pointsTransaction) ELSE 0 END ) AS qtdPointsNoite,

    1.0 * SUM(CASE WHEN hour >= 8 AND hour < 12 THEN ABS(pointsTransaction) ELSE 0 END ) / SUM (ABS(pointsTransaction)) AS pctPointsManha,
    1.0 * SUM(CASE WHEN hour >= 12 AND hour < 18 THEN ABS(pointsTransaction) ELSE 0 END ) / SUM (ABS(pointsTransaction)) AS pctPointsTarde,
    1.0 * SUM(CASE WHEN hour >= 18 AND hour <= 23 THEN ABS(pointsTransaction) ELSE 0 END ) / SUM (ABS(pointsTransaction)) AS pctPointsNoite,

    SUM(CASE WHEN hour >= 8 AND hour < 12 THEN 1 ELSE 0 END ) AS qtdTransacoesManha,
    SUM(CASE WHEN hour >= 12 AND hour < 18 THEN 1 ELSE 0 END ) AS qtdTransacoesTarde,
    SUM(CASE WHEN hour >= 18 AND hour <= 23 THEN 1 ELSE 0 END ) AS qtdTransacoesNoite,

    1.0 * SUM(CASE WHEN hour >= 8 AND hour < 12 THEN 1 ELSE 0 END)/ SUM (1) AS pctTransacoesManha,
    1.0 * SUM(CASE WHEN hour >= 12 AND hour < 18 THEN 1 ELSE 0 END)/ SUM (1) AS pctTransacoesTarde,
    1.0 * SUM(CASE WHEN hour >= 18 AND hour <= 23 THEN 1 ELSE 0 END)/ SUM (1) AS pctTransacoesNoite


FROM  tb_transactions_hour
GROUP BY idCustomer )

SELECT
    '{date}' AS dtRef,
    * 
FROM tb_share