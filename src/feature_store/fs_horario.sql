WITH tb_transactions_hour AS (

SELECT idCustomer,
  pointsTransaction,
  CAST( strftime('%H', datetime(dtTransaction, '-3 hour')) AS INTEGER) AS hour

FROM transactions

WHERE dtTransaction < '2024-06-05'
AND dtTransaction >= DATE('2024-06-05', '-21 day')
)

SELECT
  idCustomer,
  SUM(CASE WHEN hour >=8 and hour < 12 THEN abs(pointsTransaction) ELSE 0 END) as qtdPointsManha,
  SUM(CASE WHEN hour >=12 and hour < 18 THEN abs(pointsTransaction) ELSE 0 END) as qtdPointsTarde,
  SUM(CASE WHEN hour >=18 and hour <= 23 THEN abs(pointsTransaction) ELSE 0 END) as qtdPointsNoite,

  1.0 * SUM(CASE WHEN hour >=8 and hour < 12 THEN abs(pointsTransaction) ELSE 0 END)  / SUM (abs(pointsTransaction)) AS pctPointsManha,
  1.0 * SUM(CASE WHEN hour >=12 and hour < 18 THEN abs(pointsTransaction) ELSE 0 END)  / SUM (abs(pointsTransaction)) AS pctPointsTarde,
  1.0 * SUM(CASE WHEN hour >=18 and hour <= 23 THEN abs(pointsTransaction) ELSE 0 END) / SUM (abs(pointsTransaction)) AS pctPointsNoite,

  SUM(CASE WHEN hour >=8 and hour < 12 THEN abs(pointsTransaction) ELSE 0 END) as qtdTransacoesManha,
  SUM(CASE WHEN hour >=12 and hour < 18 THEN abs(pointsTransaction) ELSE 0 END) as qtdTransacoesTarde,
  SUM(CASE WHEN hour >=18 and hour <= 23 THEN abs(pointsTransaction) ELSE 0 END) as qtdTransacoesNoite,

  1.0 * SUM(CASE WHEN hour >=8 and hour < 12 THEN abs(pointsTransaction) ELSE 0 END)  / SUM(1) AS pctTransacoesManha,
  1.0 * SUM(CASE WHEN hour >=12 and hour < 18 THEN abs(pointsTransaction) ELSE 0 END)  / SUM(1) AS pctTransacoesTarde,
  1.0 * SUM(CASE WHEN hour >=18 and hour <= 23 THEN abs(pointsTransaction) ELSE 0 END) / SUM(1) AS pctTransacoessNoite


FROM tb_transactions_hour

GROUP BY idCustomer
