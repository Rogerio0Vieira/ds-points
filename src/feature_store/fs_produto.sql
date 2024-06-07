--Realzando um cte
WITH tb_transactions_products AS (

SELECT t1.*,
        t2.NameProduct,
        t2.QuantityProduct

FROM transactions AS t1

LEFT JOIN transactions_product AS t2
ON t1.idTransaction = t2.idTransaction

WHERE t1.dtTransaction < '{date}'
AND t1.dtTransaction >= DATE('{date}', '-21 day') -- Filtro de 21 dias

),

--Agrupando por quantidade de produtos comprados de acordo com o usuario dos ultimos 21 dias

tb_share AS (

    SELECT

        idCustomer,
        --Quantidade de produto
        SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS qtdeChatMessage,
        SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS qtdeListaPresença,
        SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS qtdePonei,
        SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS qtdeTrocaPontos,
        SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS qtdePresençaStreak,
        SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS qtdeAirflowLover,
        SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS qtdeRLover,
        --quantidade de pontos por produto
        SUM(CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS pointsChatMessage,
        SUM(CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS pointsListaPresença,
        SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS pointsPonei,
        SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElement' THEN pointsTransaction ELSE 0 END) AS pointsTrocaPontos,
        SUM(CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS pointsPresençaStreak,
        SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS pointsAirflowLover,
        SUM(CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS pointsRLover,
        -- % de pontos por produto
        1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChatMessage,
        1.0 * SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctListaPresença,
        1.0 * SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctPonei,
        1.0 * SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctTrocaPontos,
        1.0 * SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctPresençaStreak,
        1.0 * SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctAirflowLover,
        1.0 * SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctRLover,

        SUM(CASE WHEN  NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) as acgChatLive

    FROM tb_transactions_products

    GROUP BY idCustomer

),

tb_group AS (

SELECT idCustomer,
       NameProduct,
       SUM(QuantityProduct) AS qtde,
       SUM(pointsTransaction) AS points

FROM tb_transactions_products
GROUP BY idCustomer, NameProduct

),

tb_rn AS (

SELECT *,
    ROW_NUMBER() OVER(PARTITION BY idCustomer ORDER BY qtde DESC, points DESC) AS rnQtde -- pega a ordem do produto mais comprado do usuario

    FROM tb_group
    ORDER BY idCustomer

),

tb_produto_max AS (

SELECT * FROM tb_rn WHERE rnQtde = 1
)

SELECT
       '{date}' AS dtRef,
       t1.*,
       t2.NameProduct AS productMaxQtde

FROM tb_share AS t1

LEFT JOIN tb_produto_max AS t2
ON t1.idCustomer = t2.idCustomer
