-- =====================================================================================
--  ARQUIVO 3:  CONSTRUCAO DAS DIMENSOES E DA PONTE
--  Case: Pata Amiga  |  PostgreSQL 16
-- =====================================================================================
--  Rode depois de: 01-carga-staging.sql e 02-dimensoes-prontas.sql


--  DIM_CATEGORIA
INSERT INTO dim_categoria (sk_categoria, categoria_origem, nome_categoria, grupo_categoria)
VALUES (-1, 'N/I', 'Nao Informado', 'Nao Informado');

INSERT INTO dim_categoria (categoria_origem, nome_categoria, grupo_categoria)
SELECT DISTINCT
    "CategoriaProduto",
    CASE
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%MED%'    THEN 'Medicamento'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%PETISC%' THEN 'Petisco'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%RA%'     THEN 'Racao'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%HIG%'    THEN 'Higiene'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%BRINQ%'  THEN 'Brinquedo'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%ACESS%'  THEN 'Acessorio'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%SERV%'   THEN 'Servico'
        ELSE 'Nao Informado'
    END AS nome_categoria,
    CASE
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%MED%'    THEN 'Saude e Higiene'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%PETISC%' THEN 'Alimentacao'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%RA%'     THEN 'Alimentacao'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%HIG%'    THEN 'Saude e Higiene'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%BRINQ%'  THEN 'Bem-estar'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%ACESS%'  THEN 'Bem-estar'
        WHEN UPPER(TRANSLATE("CategoriaProduto",
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')) LIKE '%SERV%'   THEN 'Bem-estar'
        ELSE 'Nao Informado'
    END AS grupo_categoria
FROM stg_pedido;


--  DIM_PRACA
INSERT INTO dim_praca (sk_praca, cod_praca, nome_praca, regional, domicilios_com_pet)
VALUES (-1, 'N/I', 'Nao Informado', 'Nao Informado', NULL);

INSERT INTO dim_praca (cod_praca, nome_praca, regional, domicilios_com_pet)
SELECT DISTINCT
    "CodPraca",
    "NomePraca",
    "Regional",
    CAST(REPLACE("DomiciliosComPet", '.', '') AS INTEGER)
FROM stg_loja_praca;


--  BRIDGE_LOJA_PRACA
INSERT INTO bridge_loja_praca (cod_loja, sk_praca, fator_publico)
SELECT
    lp."CodLoja",
    p.sk_praca,
    CAST(lp."PercentualPublico" AS DECIMAL(6,4))
FROM stg_loja_praca lp
JOIN dim_praca p
    ON p.cod_praca = lp."CodPraca";