WITH tb_transactions AS(

  SELECT *
  FROM transactions
  WHERE dtTransaction < '{date}'
  AND dtTransaction >= date('{date}5', '-21 day')

),

tb_freq AS (
  SELECT
    idCustomer,
    COUNT(DISTINCT date(dtTransaction)) AS qtdDiasD21,
    COUNT(DISTINCT CASE WHEN dtTransaction > date('{date}', '-14 day') THEN date(dtTransaction) END) AS qtdDiasD14,
    COUNT(DISTINCT CASE WHEN dtTransaction > date('{date}', '-7 day') THEN date(dtTransaction) END) AS qtdDiasD7

FROM tb_transactions

GROUP BY idCustomer

),

tb_live_minutes AS (

  SELECT
    idCustomer,

    date(datetime(dtTransaction, '-3 hour')) AS dtTransactionDate,
    min(datetime(dtTransaction, '-3 hour')) AS dtInicio,
    max(datetime(dtTransaction, '-3 hour')) AS dtFim,
  (julianday( max(datetime(dtTransaction, '-3 hour'))) -
  julianday(min(datetime(dtTransaction, '-3 hour')))) * 24 * 60 AS liveMinutes


  FROM tb_transactions

  GROUP BY 1,2
),

tb_hours AS(

  SELECT
    idCustomer,
    AVG(liveMinutes) as avgMinutes,
    SUM(liveMinutes) as sumLiveMinutes,
    min(liveMinutes) as minLiveMinutes,
    max(liveMinutes) as maxLiveMinutes

  FROM tb_live_minutes

  GROUP BY idCustomer
),

tb_vida AS (

  SELECT idCustomer,
    COUNT(DISTINCT idTransaction ) as qtdeTransacaoVida,
    COUNT(DISTINCT idTransaction ) / (max(julianday('{date}') - julianday(dtTransaction))) AS avgTransacaoPorDia
  FROM transactions
  WHERE dtTransaction < '{date}'
  GROUP BY idCustomer
),

tb_join AS (

  SELECT
    t1.*,
    t2.avgMinutes,
    t2.sumLiveMinutes,
    t2.minLiveMinutes,
    t2.maxLiveMinutes,
    t3.qtdeTransacaoVida,
    t3.avgTransacaoPorDia

  FROM tb_freq as t1

  LEFT JOIN tb_hours AS t2
  ON t1.idCustomer = t2.idCustomer

  LEFT JOIN tb_vida as t3
  ON t3.idCustomer = t1.idCustomer

)

SELECT
  '{date}' as dtRef,
  *
FROM tb_join
