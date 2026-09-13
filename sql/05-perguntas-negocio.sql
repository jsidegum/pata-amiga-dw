-- =====================================================================================
--  ARQUIVO 5:  AS CINCO PERGUNTAS DE NEGOCIO
--  Case: Pata Amiga  |  PostgreSQL 16
-- =====================================================================================
--  Rode depois de: 01, 02, 03 e 04 (o DW precisa estar completo: fato_pedido com as 4.044 linhas).

-- =====================================================================================
--  P1 - ONDE ESTA O GARGALO DA ENTREGA?
-- =====================================================================================
-- Rede:
SELECT
    ROUND(AVG(dias_total_ate_entrega), 1)      AS media_dias_erp_ate_entrega,
    ROUND(AVG(dias_integracao_separacao), 1)   AS media_integracao_separacao,
    ROUND(AVG(dias_separacao_nota), 1)         AS media_separacao_nota,
    ROUND(AVG(dias_nota_despacho), 1)          AS media_nota_despacho,
    ROUND(AVG(dias_despacho_entrega), 1)       AS media_despacho_entrega
FROM fato_pedido;

-- Por porte de loja:
SELECT
    dl.porte,
    ROUND(AVG(f.dias_integracao_separacao), 1) AS media_integracao_separacao,
    ROUND(AVG(f.dias_separacao_nota), 1)       AS media_separacao_nota,
    ROUND(AVG(f.dias_nota_despacho), 1)        AS media_nota_despacho,
    ROUND(AVG(f.dias_despacho_entrega), 1)     AS media_despacho_entrega,
    ROUND(AVG(f.dias_total_ate_entrega), 1)    AS media_total_ate_entrega
FROM fato_pedido f
JOIN dim_loja dl ON dl.sk_loja = f.sk_loja
GROUP BY dl.porte
ORDER BY dl.porte;


-- =====================================================================================
--  P2 - QUAL CATEGORIA CONCENTRA O FATURAMENTO?
-- =====================================================================================
--Rede:
SELECT
    dc.nome_categoria,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(f.vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2)
        AS percentual_do_total
FROM fato_pedido f
JOIN dim_categoria dc ON dc.sk_categoria = f.sk_categoria
GROUP BY dc.nome_categoria
ORDER BY faturamento DESC;

-- Por porte de loja:
SELECT
    dl.porte,
    dc.nome_categoria,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento
FROM fato_pedido f
JOIN dim_categoria dc ON dc.sk_categoria = f.sk_categoria
JOIN dim_loja dl ON dl.sk_loja = f.sk_loja
GROUP BY dl.porte, dc.nome_categoria
ORDER BY dl.porte, faturamento DESC;


-- =====================================================================================
--  P3 - O DESCONTO FUNCIONA IGUAL EM TODO CANAL?
-- =====================================================================================
SELECT
    canal_pedido,
    houve_desconto,
    ROUND(AVG(vl_liquido), 2) AS ticket_medio,
    COUNT(*)                  AS pedidos
FROM fato_pedido
GROUP BY canal_pedido, houve_desconto
ORDER BY canal_pedido, houve_desconto;

-- Quanto cada canal representa do faturamento da rede?
SELECT
    canal_pedido,
    ROUND(SUM(vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2)
        AS percentual_do_total
FROM fato_pedido
GROUP BY canal_pedido
ORDER BY faturamento DESC;


-- =====================================================================================
--  P4 - QUAL PRACA DE ATENDIMENTO CONCENTRA O FATURAMENTO?
-- =====================================================================================
SELECT
    dp.nome_praca,
    dp.domicilios_com_pet,
    ROUND(SUM(f.vl_liquido * b.fator_publico), 2) AS faturamento_rateado,
    ROUND(SUM(f.vl_liquido * b.fator_publico) / dp.domicilios_com_pet, 4)
        AS faturamento_por_domicilio_com_pet
FROM fato_pedido f
JOIN dim_loja dl          ON dl.sk_loja = f.sk_loja
JOIN bridge_loja_praca b  ON b.cod_loja = dl.cod_loja
JOIN dim_praca dp         ON dp.sk_praca = b.sk_praca
GROUP BY dp.nome_praca, dp.domicilios_com_pet
ORDER BY faturamento_rateado DESC;

-- conferencia de fechamento (mesma logica do 00-conferencia.sql): o rateio
-- por praca mais os pedidos sem loja tem de fechar com o total da rede. A
-- diferenca e arredondada UMA vez, para o arredondamento por linha nao
-- sobrar 1 ou 2 reais que na verdade fecham exato. A ultima coluna deve
-- dar ZERO.
SELECT
    (SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido) AS total_da_rede,
    (SELECT ROUND(SUM(f.vl_liquido * b.fator_publico))
       FROM fato_pedido f
       JOIN dim_loja l ON l.sk_loja = f.sk_loja
       JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja) AS soma_rateada,
    (SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido WHERE sk_loja = -1) AS sem_loja,
    ROUND(
        (SELECT SUM(vl_liquido) FROM fato_pedido)
        - (SELECT SUM(f.vl_liquido * b.fator_publico)
             FROM fato_pedido f
             JOIN dim_loja l ON l.sk_loja = f.sk_loja
             JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja)
        - (SELECT SUM(vl_liquido) FROM fato_pedido WHERE sk_loja = -1)
    ) AS diferenca_tem_de_dar_zero;


-- =====================================================================================
--  P5 - ONDE ABRIR A PROXIMA LOJA, E O QUE OS DADOS NAO PERMITEM AFIRMAR?
-- =====================================================================================
--  Ranking por ITENS VENDIDOS POR MIL HABITANTES da cidade cruzado com o tempo medio de entrega.
SELECT
    dl.nome_loja,
    dl.cidade,
    dl.populacao_cidade,
    SUM(f.qt_itens) AS itens_vendidos,
    ROUND(SUM(f.qt_itens) / (dl.populacao_cidade / 1000.0), 3) AS itens_por_mil_habitantes,
    ROUND(AVG(f.dias_total_ate_entrega), 1) AS media_dias_entrega
FROM fato_pedido f
JOIN dim_loja dl ON dl.sk_loja = f.sk_loja
WHERE dl.sk_loja <> -1
GROUP BY dl.sk_loja, dl.nome_loja, dl.cidade, dl.populacao_cidade
ORDER BY itens_por_mil_habitantes DESC;

-- Faturamento por faixa de franquia ATUAL:
SELECT
    dl.faixa_franquia,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(f.vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2)
        AS percentual_do_total
FROM fato_pedido f
JOIN dim_loja dl ON dl.sk_loja = f.sk_loja
GROUP BY dl.faixa_franquia
ORDER BY faturamento DESC;

-- O que ficou de fora:
SELECT 'Pedidos sem loja identificada' AS o_que_ficou_de_fora, COUNT(*) AS quantidade
FROM fato_pedido WHERE sk_loja = -1
UNION ALL
SELECT 'Entregas ainda nao concluidas (sem data de entrega)', COUNT(*)
FROM fato_pedido WHERE sk_tempo_entrega = -1
UNION ALL
SELECT 'Pedidos com quantidade de itens em branco', COUNT(*)
FROM fato_pedido WHERE qt_itens IS NULL
UNION ALL
SELECT 'Pedidos com valor liquido em branco', COUNT(*)
FROM fato_pedido WHERE vl_liquido IS NULL
ORDER BY quantidade DESC;

-- Detalhe do "Entregas ainda nao concluidas (sem data de entrega)":
SELECT
    sp."SituacaoPedido" AS situacao,
    COUNT(*) AS pedidos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fato_pedido WHERE sk_tempo_entrega = -1), 1)
        AS percentual_do_sem_entrega
FROM fato_pedido f
JOIN stg_pedido sp ON sp."NumeroPedido" = f.numero_pedido
WHERE f.sk_tempo_entrega = -1
GROUP BY sp."SituacaoPedido"
ORDER BY pedidos DESC;
