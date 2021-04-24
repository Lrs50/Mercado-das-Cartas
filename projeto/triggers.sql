CREATE OR REPLACE TRIGGER atualizando
    AFTER
    INSERT
    ON TRANSACAO
    FOR EACH ROW
DECLARE 
V_NUM_VENDAS VENDEDOR.NUM_VENDAS%TYPE;
VC_QTD CARTA.QTD%TYPE;
BEGIN
--Procura o numero de vendas do vendedor
SELECT NUM_VENDAS INTO V_NUM_VENDAS FROM VENDEDOR 
WHERE CPF = :new.VENDEDOR; 
--Procura o numero de CARTAS DE DETERMINADA VERSAO DO VENDEDOR
SELECT QTD INTO VC_QTD FROM CARTA 
WHERE CPF_PESSOA = :new.VENDEDOR AND VERSAO = :new.VERSAO; 

UPDATE CARTA SET CARTA.QTD = (VC_QTD - :new.QUANTIDADE) WHERE CARTA.CPF_PESSOA = :new.VENDEDOR AND CARTA.VERSAO = :new.VERSAO; 
UPDATE VENDEDOR SET VENDEDOR.num_vendas = (V_NUM_VENDAS + 1) WHERE VENDEDOR.cpf = :new.VENDEDOR;
END; 

-- aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
CREATE OR REPLACE TRIGGER validando
    BEFORE
    INSERT
    ON TRANSACAO
    FOR EACH ROW
DECLARE 
VC_QTD CARTA.QTD%TYPE; 
QTD_NAO_SUFICIENTE EXCEPTION; 
PRAGMA exception_init (QTD_NAO_SUFICIENTE, -131313); 
BEGIN
--Procura o numero de vendas do vendedor
SELECT QTD INTO VC_QTD FROM CARTA 
WHERE CPF_PESSOA = :new.VENDEDOR AND VERSAO = :new.VERSAO; 
if (VC_QTD - :new.QUANTIDADE <0) THEN
RAISE_APPLICATION_ERROR (-131313, 'ERROR');
END IF;
--UPDATE CARTA SET CARTA.QTD = (VC_QTD - :new.QUANTIDADE) WHERE CARTA.CPF_PESSOA = :new.VENDEDOR AND CARTA.VERSAO = :new.VERSAO; 
--UPDATE VENDEDOR SET VENDEDOR.num_vendas = (V_NUM_VENDAS + 1) WHERE VENDEDOR.cpf = :new.VENDEDOR;
EXCEPTION 
WHEN QTD_NAO_SUFICIENTE THEN 
DBMS_OUTPUT.PUT_LINE('O VENDEDOR ' || :new.VENDEDOR ||'NAO TEM CARTAS ' || :new.VERSAO || ' SUFICIENTE');
END; 