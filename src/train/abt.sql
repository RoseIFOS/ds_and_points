-- Analytical Base Table

WITH tb_churn AS (

    SELECT

        t1.dtRef,
        t1.idCustomer,
        CASE 
            WHEN t2.idCustomer IS NULL THEN 1 ELSE 0 
        END AS flChurn


    FROM fs_general AS t1

    LEFT JOIN fs_general AS t2
    ON t1.idCustomer = t2.idCustomer
    AND t1.dtRef = DATE(t2.dtRef, '-21 DAY')

    WHERE t1.dtRef < DATE ('2024-06-06', '-21 DAY')
    AND strftime('%d', t1.dtRef) = '01'

    ORDER BY 1,2
)

SELECT 
    t1.*,
-- Trazendo demais dados fs_general
    t2.recenciaDias,
    t2.frequenciaDias,
    t2.valorPoints,
    t2.idadeBaseDias,
    t2.flEmail,

-- Trazendo dados da fs_horario
    t3.qtdPointsManha,
    t3.qtdPointsTarde,
    t3.qtdPointsNoite,
    t3.pctPointsManha,
    t3.pctPointsTarde,
    t3.pctPointsNoite,
    t3.qtdTransacoesManha,
    t3.qtdTransacoesTarde,
    t3.qtdTransacoesNoite,
    t3.pctTransacoesManha,
    t3.pctTransacoesTarde,
    t3.pctTransacoesNoite,

-- Trazendo dados fs_points
    t4.saldoPointsD21,
    t4.saldoPointsD14,
    t4.saldoPointsD7,
    t4.pointsAcumuladosD21,
    t4.pointsAcumuladosD14,
    t4.pointsAcumuladosD7,
    t4.pointsResgatadosD21,
    t4.pointsResgatadosD14,
    t4.pointsResgatadosD7,
    t4.saldoPoints,
    t4.pointsAcumuladosVida,
    t4.pointsResgatadosVida,
    t4.pointsPorDia,

-- Trazendo dados fs_produtos
    t5.qtdeChatMessage,
    t5.qtdeListadePresenca,
    t5.qtdeResgatarPonei,
    t5.qtdeTrocaPontos,
    t5.qtdePresencaStreak,
    t5.qtdeAirflowLover,
    t5.qtdeRLover,
    t5.pointsChatMessage,
    t5.pointsListadePresenca,
    t5.pointsResgatarPonei,
    t5.pointsTrocaPontos,
    t5.pointsPresencaStreak,
    t5.pointsAirflowLover,
    t5.pointsRLover,
    t5.pctChatMessage,
    t5.pctListadePresenca,
    t5.pctResgatarPonei,
    t5.pctTrocaPontos,
    t5.pctPresencaStreak,
    t5.pctAirflowLover,
    t5.pctRLover,
    t5.avgChatLive,
    t5.productMaxQtde,

--Trazendo dados da fs_transacoes
    t6.qtdDiasD21,
    t6.qtdDiasD14,
    t6.qtdDiasD7,
    t6.avgLiveMinutes,
    t6.sumLiveMinutes,
    t6.minLiveMinutes,
    t6.maxLiveMinutes,
    t6.qtdeTransacoesVida,
    t6.avgTransacaoDia

FROM tb_churn AS t1

LEFT JOIN fs_general AS t2
ON t1.idCustomer = t2.idCustomer
AND t1.dtRef = t2.dtRef

LEFT JOIN fs_horario AS t3
ON t1.idCustomer = t3.idCustomer
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_points AS t4
ON t1.idCustomer = t4.idCustomer
AND t1.dtRef = t4.dtRef

LEFT JOIN fs_produtos AS t5
ON t1.idCustomer = t5.idCustomer
AND t1.dtRef = t5.dtRef

LEFT JOIN fs_transacoes AS t6
ON t1.idCustomer = t6.idCustomer
AND t1.dtRef = t6.dtRef