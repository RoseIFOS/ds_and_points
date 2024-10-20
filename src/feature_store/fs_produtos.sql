

WITH tb_transactions_products AS (
SELECT 

    t1.*,
    t2.NameProduct,
    t2.QuantityProduct

FROM transactions AS t1

LEFT JOIN transactions_product AS t2
on t1.idTransaction = t2.idTransaction

WHERE t1.dtTransaction < '{date}'
AND t1.dtTransaction >= date ('{date}', '-21 day')),

tb_share AS (

SELECT 
    idCustomer,
    sum(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS qtdeChatMessage,
    sum(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS qtdeListadePresenca,
    sum(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS qtdeResgatarPonei,
    sum(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS qtdeTrocaPontos,
    sum(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS qtdePresencaStreak,
    sum(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS qtdeAirflowLover,
    sum(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS qtdeRLover,

    
    sum(CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS pointsChatMessage,
    sum(CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS pointsListadePresenca,
    sum(CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS pointsResgatarPonei,
    sum(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN pointsTransaction ELSE 0 END) AS pointsTrocaPontos,
    sum(CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS pointsPresencaStreak,
    sum(CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS pointsAirflowLover,
    sum(CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS pointsRLover,



    1.0 * sum(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END)/sum(QuantityProduct) AS pctChatMessage,
    1.0 * sum(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END)/sum(QuantityProduct) AS pctListadePresenca,
    1.0 * sum(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END)/sum(QuantityProduct) AS pctResgatarPonei,
    1.0 * sum(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END)/sum(QuantityProduct) AS pctTrocaPontos,
    1.0 * sum(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) /sum(QuantityProduct) AS pctPresencaStreak,
    1.0 * sum(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) /sum(QuantityProduct) AS pctAirflowLover,
    1.0 * sum(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END)/sum(QuantityProduct) AS pctRLover,

    1.0 * sum(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE (dtTransaction)) AS avgChatLive

FROM tb_transactions_products
GROUP BY idCustomer),

-- CALCULAR PRODUTO COM MAIS PONTOS E MENOS PONTOS

tb_group AS (

-- AGRUPANDO DADOS
SELECT 
    idCustomer,
    NameProduct,
    SUM(QuantityProduct) AS qtde,
    SUM(pointsTransaction) AS points
 
FROM tb_transactions_products
GROUP BY idCustomer , NameProduct),

-- RANKEANDO POR USUÁRIO

tb_rn AS (
SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY idCustomer ORDER BY qtde DESC, points DESC)  AS rnQtde

FROM tb_group),

tb_produto_max AS (

-- FILTRANDO APENAS O PRODUTO MAIS COMPRADO

SELECT *
FROM tb_rn
WHERE rnQtde = 1)

-- JUNTANDO AS TABELAS
SELECT 
    '{date}' AS dtRef,
    t1.*,
    t2.NameProduct AS productMaxQtde
FROM tb_share AS t1

LEFT JOIN tb_produto_max AS t2
ON t1.idCustomer = t2.idCustomer