-- =====================================================================================
--  ARQUIVO 4:  CONSTRUCAO DA FATO_PEDIDO
--  Case: Pata Amiga  |  PostgreSQL 16
-- =====================================================================================
--  Rode depois de: 01-carga-staging.sql, 02-dimensoes-prontas.sql e 03-carga-dimensoes.sql.
INSERT INTO fato_pedido (
    numero_pedido,
    sk_tempo_pedido,
    sk_tempo_entrega,
    sk_loja,
    sk_categoria,
    houve_desconto,
    canal_pedido,
    dt_pedido,
    qt_itens,
    vl_liquido,
    dias_integracao_separacao,
    dias_separacao_nota,
    dias_nota_despacho,
    dias_despacho_entrega,
    dias_total_ate_entrega
)
SELECT
    sp."NumeroPedido" AS numero_pedido,
    CAST(TO_CHAR(TO_TIMESTAMP(sp."DtHoraPedido", 'MM/DD/YYYY HH12:MI AM'), 'YYYYMMDD') AS INT)
        AS sk_tempo_pedido,
    CASE
        WHEN TRIM(sp."DtEntregaCliente") = '' THEN -1
        ELSE CAST(TO_CHAR(sp."DtEntregaCliente"::date, 'YYYYMMDD') AS INT)
    END AS sk_tempo_entrega,
    COALESCE(dl.sk_loja, -1) AS sk_loja,
    COALESCE(dc.sk_categoria, -1) AS sk_categoria,
    CASE
        WHEN UPPER(TRIM(sp."HouveDesconto")) IN ('S','SIM','1','X','TRUE','V') THEN 'Sim'
        WHEN UPPER(TRIM(sp."HouveDesconto")) IN ('N','NAO','0','FALSE','F')    THEN 'Nao'
        ELSE 'Nao Informado'
    END AS houve_desconto,
    CASE
        WHEN UPPER(sp."CanalPedido") LIKE '%WHATS%' THEN 'WhatsApp'
        WHEN UPPER(sp."CanalPedido") LIKE '%APP%'   THEN 'App'
        WHEN UPPER(sp."CanalPedido") LIKE '%SITE%'  THEN 'Site'
        WHEN UPPER(sp."CanalPedido") LIKE '%LOJA%'  THEN 'Loja Fisica'
        WHEN UPPER(sp."CanalPedido") LIKE '%TEL%'   THEN 'Telefone'
        ELSE 'Nao Informado'
    END AS canal_pedido,
    TO_TIMESTAMP(sp."DtHoraPedido", 'MM/DD/YYYY HH12:MI AM') AS dt_pedido,
    CASE
        WHEN TRIM(sp."QTD.Itens") IN ('', '-') THEN NULL
        ELSE CAST(sp."QTD.Itens" AS INTEGER)
    END AS qt_itens,
    CASE
        WHEN TRIM(REPLACE(sp."ValorLiquidoPedido(R$)", 'R$', '')) IN ('', '-') THEN NULL
        WHEN sp."ValorLiquidoPedido(R$)" LIKE '%,%'
            THEN CAST(REPLACE(REPLACE(REPLACE(REPLACE(sp."ValorLiquidoPedido(R$)", 'R$', ''), ' ', ''), '.', ''), ',', '.')
                 AS DECIMAL(15,2))
        ELSE CAST(REPLACE(REPLACE(sp."ValorLiquidoPedido(R$)", 'R$', ''), ' ', '') AS DECIMAL(15,2))
    END AS vl_liquido,
    CASE
        WHEN TRIM(sp."Dt Separacao Estoque") = '' THEN NULL
        ELSE sp."Dt Separacao Estoque"::date
             - TO_TIMESTAMP(sp."DtHoraIntegracaoERP", 'MM/DD/YYYY HH12:MI AM')::date
    END AS dias_integracao_separacao,
    CASE
        WHEN TRIM(sp."Dt Separacao Estoque") = '' OR TRIM(sp."DtNotaFiscal") = '' THEN NULL
        ELSE sp."DtNotaFiscal"::date - sp."Dt Separacao Estoque"::date
    END AS dias_separacao_nota,
    CASE
        WHEN TRIM(sp."DtNotaFiscal") = '' OR TRIM(sp."Dt_Despacho_Transportadora") = '' THEN NULL
        ELSE sp."Dt_Despacho_Transportadora"::date - sp."DtNotaFiscal"::date
    END AS dias_nota_despacho,
    CASE
        WHEN TRIM(sp."Dt_Despacho_Transportadora") = '' OR TRIM(sp."DtEntregaCliente") = '' THEN NULL
        ELSE sp."DtEntregaCliente"::date - sp."Dt_Despacho_Transportadora"::date
    END AS dias_despacho_entrega,
    CASE
        WHEN TRIM(sp."DtEntregaCliente") = '' THEN NULL
        ELSE sp."DtEntregaCliente"::date
             - TO_TIMESTAMP(sp."DtHoraIntegracaoERP", 'MM/DD/YYYY HH12:MI AM')::date
    END AS dias_total_ate_entrega
FROM stg_pedido sp
LEFT JOIN dim_loja dl
    ON dl.chave_loja =
        CASE
            WHEN UPPER(TRANSLATE(TRIM(REPLACE(REPLACE(sp."Loja-Nome", '/SC', ''), '  ', ' ')),
                    'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                    'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) = 'PATA AMIGA BLUMENAL CENTRO'
                THEN 'PATA AMIGA BLUMENAU CENTRO'
            WHEN UPPER(TRANSLATE(TRIM(REPLACE(REPLACE(sp."Loja-Nome", '/SC', ''), '  ', ' ')),
                    'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                    'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) = 'PATA AMIGA FLORIPA NORTE'
                THEN 'PATA AMIGA FLORIANOPOLIS NORTE'
            WHEN UPPER(TRANSLATE(TRIM(REPLACE(REPLACE(sp."Loja-Nome", '/SC', ''), '  ', ' ')),
                    'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                    'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) = 'PATA AMIGA JGUA DO SUL'
                THEN 'PATA AMIGA JARAGUA DO SUL'
            ELSE UPPER(TRANSLATE(TRIM(REPLACE(REPLACE(sp."Loja-Nome", '/SC', ''), '  ', ' ')),
                    'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                    'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'))
        END
LEFT JOIN dim_categoria dc
    ON dc.categoria_origem = sp."CategoriaProduto";