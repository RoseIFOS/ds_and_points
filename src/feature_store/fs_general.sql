-- Base ativa é quem esta em uma janela de 21 dias
-- {date} (última data da base, today)

with tb_rfv as (
SELECT
    idCustomer,
    -- Calculando a recência
    cast(min(julianday('{date}') - julianday(dtTransaction)) 
    as INTERGER) + 1 AS recenciaDias,

    -- Calculando a frequencia
    COUNT(DISTINCT DATE(dtTransaction)) as frequenciaDias,

    -- Calculando o total de pontos positivos
    SUM(CASE WHEN pointsTransaction > 0
        THEN pointsTransaction
        END
    ) as valorPoints

FROM transactions
WHERE dtTransaction < '{date}'
AND dtTransaction >= DATE ('{date}', '-21 day')

GROUP BY idCustomer),
    
tb_idade as (SELECT 
	t1.idCustomer,
	
    -- Calculando a recência dos usuários da base ativa
	
    cast(max(julianday('{date}') - julianday(t2.dtTransaction))
    as INTERGER) + 1 AS idadeBaseDias
    
FROM tb_rfv as t1

left join transactions as t2
on t1.idcustomer = t2.idcustomer

group by t2.idcustomer)

SELECT 
    '{date}' as dtRef,
    t1.*,
    t2.idadeBaseDias,
    t3.flEmail

FROM tb_rfv as t1

LEFT JOIN tb_idade as t2
on t1.idCustomer = t2.idCustomer

LEFT JOIN customers as t3
ON t1.idCustomer = t3.idCustomer