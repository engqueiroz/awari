
SELECT   a.pk_tabela_pai
FROM     dbo.tabela_pai   a
LEFT JOIN dbo.tabela_filha b
ON       a.pk_tabela_pai   = b.fk_tabela_filha
WHERE    b.fk_tabela_filha IS NULL
GO
SELECT   a.pk_tabela_pai
FROM     dbo.tabela_pai a
WHERE NOT EXISTS(SELECT *
                FROM   dbo.tabela_filha b
WHERE  a.pk_tabela_pai
       b.fk_tabela_filha)




/* PARTE 1: DECLARAÇÃO DAS VARIÁVEIS DO CURSOR */
-- Declaração das variáveis que armazenarão as colunas
-- retornadas do SELECT da DECLARAÇÃO DO CURSOR
--
DECLARE  @nr_contato             INT           ,
@nr_empregado           INT           ,
@nr_gerente             INT           ,
@ds_emp_primeiro_nome   VARCHAR(50)   ,
@ds_emp_nome_do_meio    VARCHAR(50)   ,
@ds_emp_nome_de_familia VARCHAR(50)   ,
@ds_ger_primeiro_nome   VARCHAR(50)   ,
@ds_ger_nome_do_meio    VARCHAR(50)   ,
@ds_ger_nome_de_familia VARCHAR(50)   ,
@ds_emp_nome_completo   VARCHAR(100)  ,
@ds_ger_nome_completo   VARCHAR(100)  ,

/* PARTE 2: DECLARAÇÃO DO CURSOR */
-- Definição do SELECT que o cursor irá trabalhar
--
DECLARE  cr_empregado CURSOR FOR
         SELECT   tb_empregado.nr_empregado        ,
                   tb_empregado.nr_gerente          ,
                   tb_contato.ds_primeiro_nome      ,
                   tb_contato.ds_nome_do_meio       ,
                   tb_contato.ds_nome_de_familia
         FROM     db_pessoa_p.tb_contato
              JOIN db_recursos_humanos.tb_empregado
              ON   tb_contato.nr_contato
              =    tb_empregado.nr_contato

/* PARTE 3: ABERTURA DO CURSOR */
-- Neste momento recursos de memória
-- são alocados para o cursor
--
OPEN cr_empregado

/* PARTE 4: SENTENÇA FECTH */
-- Pega a primeira linha do SELECT da DECLARAÇÃO DO CURSOR
-- E armazena nas variáveis declaradas na PARTE 1
--
FETCH NEXT FROM cr_empregado
INTO  @nr_empregado              ,
      @nr_gerente            ,
      @ds_emp_primeiro_nome  ,
      @ds_emp_nome_do_meio   ,
      @ds_emp_nome_de_familia

-- Enquanto tiver linha a ser retornada pelo SELECT
-- da DECLARAÇÃO DO CURSOR, faça...
--
WHILE @@FETCH_STATUS = 0
  BEGIN
  SELECT
    @ds_ger_primeiro_nome   = tb_contato.ds_primeiro_nome,
    @ds_ger_nome_do_meio    = tb_contato.ds_nome_do_meio ,
    @ds_ger_nome_de_familia = tb_contato.ds_nome_de_familia
  FROM db_pessoa_p.tb_contato
         JOIN db_recursos_humanos.tb_empregado
         ON   tb_contato.nr_contato
         =    tb_empregado.nr_contato
  WHERE  tb_empregado.nr_empregado = @nr_gerente

  -- Se o SELECT acima não retornar nenhuma linha, faça...
  IF @@ROWCOUNT = 0
     BEGIN
       SET @ds_emp_nome_completo = @ds_emp_primeiro_nome
           + ISNULL(' '+@ds_emp_nome_do_meio+'. ', ' ')
           + @ds_emp_nome_de_familia
       SET @ds_ger_nome_completo = NULL
     END
  ELSE
     BEGIN
       SET @ds_emp_nome_completo = @ds_emp_primeiro_nome
           + ISNULL(' '+@ds_emp_nome_do_meio+'. ', ' ')
           + @ds_emp_nome_de_familia
       SET @ds_ger_nome_completo = @ds_ger_primeiro_nome
          + ISNULL(' '+@ds_ger_nome_do_meio+'. ', ' ')
          + @ds_ger_nome_de_familia
       END
  SELECT  @ds_emp_nome_completo AS Nome_do_Empregado,
         @ds_ger_nome_completo AS Nome_do_Gerente

  FETCH NEXT FROM cr_empregado
  INTO  @nr_empregado            ,
        @nr_gerente                   ,
        @ds_emp_primeiro_nome         ,
        @ds_emp_nome_do_meio     ,
        @ds_emp_nome_de_familia
END -– Para fechar o WHILE
CLOSE      cr_empregado –-PARTE 5:FECHANDO O CURSOR
DEALLOCATE cr_empregado –-PARTE 6:DESALOCANDO O CURSOR


-- Nova lógica da query de população do cursor
SELECT tb_empregado.nr_empregado,
       tb_empregado.nr_gerente  ,
       tb_contato.ds_primeiro_nome
       + ISNULL(' '+tb_contato.ds_nome_do_meio+'. ', ' ')
       + tb_contato.ds_nome_de_familia AS Nome_Completo
FROM   db_pessoa_p.tb_contato
 JOIN  db_recursos_humanos.tb_empregado
   ON  tb_contato.nr_contato
    =  tb_empregado.nr_contato

-- Nova consulta da sentença WHILE
SELECT @ds_ger_nome_completo = tb_contato.ds_primeiro_nome
       + ISNULL(' '+tb_contato.ds_nome_do_meio+'. ', ' ')
       + tb_contato.ds_nome_de_familia
FROM   db_pessoa_p.tb_contato
 JOIN  db_recursos_humanos.tb_empregado
   ON  tb_contato.nr_contato
    =  tb_empregado.nr_contato
WHERE  tb_empregado.nr_empregado = @nr_gerente



-- Função que recebe o número da matrícula do gerente
-- e retorna o seu nome completo
CREATE FUNCTION dbo.NomeCompletoGerente

-- Recebe a variável
-- Número da matrícula do gerente do tipo inteiro
( @nr_gerente INT )

-- Informa que o retorno da função será um VARCHAR(100)
RETURNS VARCHAR (100)
AS
BEGIN
  -- Declaração da variável que receberá
  -- os dados do SELECT
  DECLARE @GerNomeCompleto VARCHAR(100)

  -- Seleciona o nome completo do gerente
  -- e insere na variável @GerNomeCompleto
  SELECT
        @GerNomeCompleto = tb_contato.ds_primeiro_nome
        + ISNULL(' '+tb_contato.ds_nome_do_meio+'. ', ' ')
        + tb_contato.ds_nome_de_familia
  FROM  db_pessoa_p.tb_contato
  JOIN  db_recursos_humanos.tb_empregado
    ON  tb_contato.nr_contato
     =  tb_empregado.nr_contato
  WHERE tb_empregado.nr_empregado = @nr_gerente

  -- Caso a consulta não retorne nenhuma linha, faça...
  IF @@ROWCOUNT = 0
     BEGIN
       SET @GerNomeCompleto = NULL
     END
  -- Exibe o nome complete do gerente
  RETURN @GerNomeCompleto
END



--
SELECT    CtEmp.ds_primeiro_nome
          + ISNULL(' '+ CtEmp.ds_nome_do_meio+'. ', ' ')
          + CtEmp.ds_nome_de_familia AS Nome_Completo_Emp,
          CtGer.ds_primeiro_nome
          + ISNULL(' '+ CtGer.ds_nome_do_meio+'. ', ' ')
          + CtGer.ds_nome_de_familia AS Nome_Completo_Ger
FROM      db_pessoa_p.tb_contato AS CtEmp
JOIN      db_recursos_humanos.tb_empregado
  ON      CtEmp.nr_contato = tb_empregado.nr_contato
LEFT JOIN db_recursos_humanos.tb_empregado AS Gerente
       ON Gerente.nr_empregado = tb_empregado.nr_gerente
LEFT JOIN db_pessoa_p.tb_contato AS CtGer
       ON CtGer.nr_contato = Gerente.nr_contato





--
SELECT    CtEmp.ds_primeiro_nome
          + ISNULL(' '+ CtEmp.ds_nome_do_meio+'. ', ' ')
          + CtEmp.ds_nome_de_familia AS Nome_Completo_Emp,
          CtGer.ds_primeiro_nome
          + ISNULL(' '+ CtGer.ds_nome_do_meio+'. ', ' ')
          + CtGer.ds_nome_de_familia AS Nome_Completo_Ger
FROM      db_pessoa_p.tb_contato AS CtEmp
JOIN      db_recursos_humanos.tb_empregado
  ON      CtEmp.nr_contato = tb_empregado.nr_contato
LEFT JOIN db_recursos_humanos.tb_empregado AS Gerente
       ON Gerente.nr_empregado = tb_empregado.nr_gerente
LEFT JOIN db_pessoa_p.tb_contato AS CtGer
       ON CtGer.nr_contato = Gerente.nr_contato



CREATE TABLE tb_venda
( ds_ano      INT         NOT NULL,
  ds_mes      INT         NOT NULL,
  ds_valor    NUMERIC(9,2) NOT NULL,
)
GO
INSERT INTO tb_venda VALUES (2003, 2, 10)
INSERT INTO tb_venda VALUES (2003, 2, 1)
INSERT INTO tb_venda VALUES (2003, 3, 20)
INSERT INTO tb_venda VALUES (2003, 4, 30)
INSERT INTO tb_venda VALUES (2004, 1, 40)
INSERT INTO tb_venda VALUES (2004, 2, 50)
INSERT INTO tb_venda VALUES (2004, 3, 60)
INSERT INTO tb_venda VALUES (2004, 4, 70)
INSERT INTO tb_venda VALUES (2005, 1, 80)
GO



--
SELECT   ds_ano as Ano,
    Jan = sum(case when ds_mes=1 then valor end),
    Fev = sum(case when ds_mes=2 then valor end),
    Mar = sum(case when ds_mes=3 then valor end),
    Abr = sum(case when ds_mes=4 then valor end)
FROM     tb_venda
GROUP BY ds_ano
ORDER BY ds_ano



SELECT   ds_ano as Ano,
         [1]    as Jan,
    [2]    as Fev,
    [3]    as Mar,
    [4]    as Abr
FROM     tb_venda
PIVOT   (SUM(ds_valor) FOR ds_mes IN ([1],[2],[3],[4])) p
ORDER BY 1



--
CREATE NONCLUSTERED INDEX idx_empregado
ON db_recursos_humanos.tb_empregado (nr_empregado)
INCLUDE (ds_endereco, nr_telefone, nr_CPF)


--
ALTER DATABASE db_teste
SET ALLOW_SNAPSHOT_ISOLATION ON
GO
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
