//�÷����� ���
//�ǽ�1. Varray�� �Ϲ� ���̺� �����ϱ�
//VARRAY Ÿ������ ����� ���� Ÿ���� �����ϰ� ���̺� ����
CREATE OR REPLACE TYPE country_var IS VARRAY(7) OF VARCHAR2(30);

CREATE TABLE test_continent( 
                  continent VARCHAR2(50), 
                  country_nm country_var);

desc country_var;

//�͸� ����� �����ϰ� �����͸� insert �ϱ�
BEGIN
    INSERT INTO test_continent VALUES ('Asia', country_var('�ѱ�', '�Ϻ�', '�߱�', '��Ʈ��', '��۶󵥽�'));
    INSERT INTO test_continent VALUES ('Europe', country_var('������', '����', '����', '����Ʈ����', '������'));
    INSERT INTO test_continent VALUES ('North America', country_var('�̱�', 'ĳ����'));
    INSERT INTO test_continent VALUES ('South America', country_var('���', 'ĥ��', '�����'));
 COMMIT;
END;

select * from test_continent;

//Asia�� �ش��ϴ� VARRY�� �̾ƿͼ� �ϳ��� �̾ƺ���
DECLARE
    va_continent country_var;
BEGIN
    SELECT country_nm INTO va_continent
    FROM test_continent 
    WHERE CONTINENT = 'Asia';
       FOR i IN va_continent.FIRST .. va_continent.LAST
    LOOP
       DBMS_OUTPUT.PUT_LINE(va_continent(i));
    END LOOP;
END;

//TABLE �Լ��� �÷����� ���� ���̺�ó�� �ٷ� �� �ְ� ���ִ� �Լ�
SELECT *
FROM TABLE ( SELECT t.country_nm FROM test_continent t WHERE t.continent = 'Asia') ;

SELECT continent, b.* FROM test_continent a, TABLE( a.country_nm ) b
WHERE continent  = 'Asia';

//�ǽ�2.��ø ���̺��� �Ϲ� ���̺� �����ϱ�
//��ø ���̺� ������ Ÿ���� �Ϲ� ���̺� ����
CREATE OR REPLACE TYPE country_nt IS TABLE OF VARCHAR2(30);

CREATE TABLE test_continent_nested( 
                  continent VARCHAR2(50), 
                  country_nt country_nt)
NESTED TABLE country_nt STORE AS country_nt_sp;

DECLARE
BEGIN
    INSERT INTO test_continent_nested VALUES ('Asia', country_nt('�ѱ�', '�Ϻ�', '�߱�', '��Ʈ��', '��۶󵥽�'));
    INSERT INTO test_continent_nested VALUES ('Europe', country_nt('������', '����', '����', '����Ʈ����', '������'));
    INSERT INTO test_continent_nested VALUES ('North America', country_nt('�̱�', 'ĳ����'));
    INSERT INTO test_continent_nested VALUES ('South America', country_nt('���', 'ĥ��', '�����'));
 COMMIT;
END;

SELECT *
    FROM TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia');

INSERT INTO TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia') VALUES ('����');

UPDATE TABLE ( SELECT f.country_nt FROM test_continent_nested f WHERE f.continent = 'Asia')t
            SET VALUE(t) = '�̰�����'
            WHERE t.COLUMN_VALUE = '����';
            
SELECT *
    FROM TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia');
    
DELETE FROM TABLE ( SELECT f.country_nt FROM test_continent_nested f WHERE f.continent = 'Asia')t
WHERE t.COLUMN_VALUE = '�̰�����'; 

//�Ķ���͸� ����ϴ� Ŀ�� �˾ƺ���
DECLARE
    --Ŀ�� �����͸� �Է��� �� �ִ� ���� ����
    V_DEPT_ROW DEPT%ROWTYPE;
    --����� Ŀ�� ����(Declaration)
    CURSOR c1 (p_deptno DEPT.DEPTNO%TYPE) IS
        SELECT DEPTNO, DNAME, LOC
        FROM DEPT
        WHERE DEPTNO=p_detno;
BEGIN
    --10�� �μ� ó���� ���� Ŀ�� ���
    OPEN c1(10);
    LOOP
        FETCH c1 INTO V_DEPT_ROW;
        EXIT WHEN c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('10�� �μ�-DEPTNO : ' || V_DEPT_ROW.DEPTNO
                                    ||', DNAME : ' || V_DEPT_ROW.DNAME
                                    ||', LOC : ' || V_DEPT_ROW.LOC);
    END LOOP;
    CLOSE c1;
END;
/




