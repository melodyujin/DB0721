//컬렉션의 사용
//실습1. Varray를 일반 테이블에 저장하기
//VARRAY 타입으로 사용자 정의 타입을 선언하고 테이블 생성
CREATE OR REPLACE TYPE country_var IS VARRAY(7) OF VARCHAR2(30);

CREATE TABLE test_continent( 
                  continent VARCHAR2(50), 
                  country_nm country_var);

desc country_var;

//익명 블록을 선언하고 데이터를 insert 하기
BEGIN
    INSERT INTO test_continent VALUES ('Asia', country_var('한국', '일본', '중국', '베트남', '방글라데시'));
    INSERT INTO test_continent VALUES ('Europe', country_var('프랑스', '영국', '독일', '오스트리아', '스페인'));
    INSERT INTO test_continent VALUES ('North America', country_var('미국', '캐나다'));
    INSERT INTO test_continent VALUES ('South America', country_var('페루', '칠레', '브라질'));
 COMMIT;
END;

select * from test_continent;

//Asia에 해당하는 VARRY를 뽑아와서 하나씩 뽑아보기
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

//TABLE 함수는 컬렉션을 실제 테이블처럼 다룰 수 있게 해주는 함수
SELECT *
FROM TABLE ( SELECT t.country_nm FROM test_continent t WHERE t.continent = 'Asia') ;

SELECT continent, b.* FROM test_continent a, TABLE( a.country_nm ) b
WHERE continent  = 'Asia';

//실습2.중첩 테이블을 일반 테이블에 저장하기
//중첩 테이블 데이터 타입을 일반 테이블에 저장
CREATE OR REPLACE TYPE country_nt IS TABLE OF VARCHAR2(30);

CREATE TABLE test_continent_nested( 
                  continent VARCHAR2(50), 
                  country_nt country_nt)
NESTED TABLE country_nt STORE AS country_nt_sp;

DECLARE
BEGIN
    INSERT INTO test_continent_nested VALUES ('Asia', country_nt('한국', '일본', '중국', '베트남', '방글라데시'));
    INSERT INTO test_continent_nested VALUES ('Europe', country_nt('프랑스', '영국', '독일', '오스트리아', '스페인'));
    INSERT INTO test_continent_nested VALUES ('North America', country_nt('미국', '캐나다'));
    INSERT INTO test_continent_nested VALUES ('South America', country_nt('페루', '칠레', '브라질'));
 COMMIT;
END;

SELECT *
    FROM TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia');

INSERT INTO TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia') VALUES ('몽골');

UPDATE TABLE ( SELECT f.country_nt FROM test_continent_nested f WHERE f.continent = 'Asia')t
            SET VALUE(t) = '싱가포르'
            WHERE t.COLUMN_VALUE = '몽골';
            
SELECT *
    FROM TABLE ( SELECT t.country_nt FROM test_continent_nested t WHERE t.continent = 'Asia');
    
DELETE FROM TABLE ( SELECT f.country_nt FROM test_continent_nested f WHERE f.continent = 'Asia')t
WHERE t.COLUMN_VALUE = '싱가포르'; 

//파라미터를 사용하는 커서 알아보기
DECLARE
    --커서 테이터를 입력할 수 있는 변수 선언
    V_DEPT_ROW DEPT%ROWTYPE;
    --명시적 커서 선언(Declaration)
    CURSOR c1 (p_deptno DEPT.DEPTNO%TYPE) IS
        SELECT DEPTNO, DNAME, LOC
        FROM DEPT
        WHERE DEPTNO=p_detno;
BEGIN
    --10번 부서 처리를 위해 커서 사용
    OPEN c1(10);
    LOOP
        FETCH c1 INTO V_DEPT_ROW;
        EXIT WHEN c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('10번 부서-DEPTNO : ' || V_DEPT_ROW.DEPTNO
                                    ||', DNAME : ' || V_DEPT_ROW.DNAME
                                    ||', LOC : ' || V_DEPT_ROW.LOC);
    END LOOP;
    CLOSE c1;
END;
/




