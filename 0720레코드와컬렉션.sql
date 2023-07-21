//파라미터를 사용하지 않는 프로시저
CREATE OR REPLACE PROCEDURE PROC
AS
V_EMPNO NUMBER(4) := 1234;
BEGIN
DBMS_OUTPUT.PUT_LINE('V_EMPNO : ' || V_EMPNO);
END;
/
//프로시저 PROC를 테스트하는 부분
SET SERVEROUTPUT ON ;
  exec proc;

//프로시저 실행에 필요한 값을 직접 입력 받는 형식
CREATE OR REPLACE PROCEDURE PROC_PARAMS
(
	param1 IN NUMBER,
	param2 NUMBER
)
AS
BEGIN
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
	DBMS_OUTPUT.PUT_LINE('param2: ' || param2);
END;
//프로시저 PROC를 테스트하는 부분
BEGIN 
	PROC_PARAMS(1,2);
END;

//프로시저 실행 후 호출한 프로그램으로 값을 반환 받을 수 있는 방식
CREATE OR REPLACE PROCEDURE PROC_OUT
(
	param1 OUT NUMBER
)
AS
BEGIN
	SELECT DEPTNO INTO param1
	FROM DEPT
	WHERE DEPTNO = 10;
END PROC_OUT;
//프로시저 PROC를 테스트하는 부분
DECLARE
	param1 NUMBER;
BEGIN
	PROC_OUT(param1);
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
END;

//트리거
//데이터베이스 안의 특정 상황이나 동작(이벤트)가 발생할 경우 자동으로 실행되는 기능을 가진 서브프로그램
//트리거는 데이터의 변경문이 실행될 때 자동으로 따라서 실행되는 프로시저를 말한다
CREATE OR REPLACE TRIGGER CHK_EMP
      BEFORE INSERT OR  UPDATE OF ename, sal OR DELETE ON emp
 BEGIN
      CASE
        WHEN INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('Inserting...');
        WHEN UPDATING('sal') THEN
           DBMS_OUTPUT.PUT_LINE('Updating sal...');
        WHEN UPDATING('ename') THEN
           DBMS_OUTPUT.PUT_LINE('Updating ename...');
       WHEN DELETING THEN
          DBMS_OUTPUT.PUT_LINE('Deleting...');
     END CASE;
END;
/

insert into emp (empno, ename) values (88, '88길동');
select * from emp;
update emp set sal = sal + 10 where empno = 7369;
update emp set ename = '신윤복' where empno = 7369;

//행트리거 예제
//테이블 생성
create table emp_bak (
     old_sal number,
     new_sal number,
     u_date date,
     action varchar2(20));

select * from emp_bak;
//트리거 생성
create or replace trigger tr_emp_update
      after update of sal on emp
      for each row
begin
      insert into emp_bak values (:old.sal, :new.sal, sysdate,'UPDATE');
end;
/
//emp 테이블 업데이트
update emp set sal = sal + 500;

select * from emp_bak;

//WHEN절을 이용하여 조건이 맞는 경우에만 트리거가 동작하도록 할 수 있다
CREATE OR REPLACE TRIGGER print_emp 
      BEFORE UPDATE ON emp 
      FOR EACH ROW 
      WHEN (new.sal > 500) 
DECLARE 
      sal_diff number; 
BEGIN 
      sal_diff  := :new.sal  - :old.sal; 
      dbms_output.put('OLD SALARY : ' || :old.sal); 
      dbms_output.put(',NEW SALARY : ' || :new.sal); 
      dbms_output.put_line(',급여차이 ' || sal_diff); 
END; 
/ 
update emp set sal = 0; 
select * from emp;
rollback;
select * from emp;
update emp set sal = 501; 

//자료형이 다른 여러 데이터를 저장하는 레코드
//레코드 정의해서 사용하기
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno NUMBER(2) NOT NULL := 99, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 99; 
   dept_rec.dname := 'DATABASE'; 
   dept_rec.loc := 'SEOUL'; 
   DBMS_OUTPUT.PUT_LINE('DEPTNO : ' || dept_rec.deptno); 
   DBMS_OUTPUT.PUT_LINE('DNAME : ' || dept_rec.dname); 
   DBMS_OUTPUT.PUT_LINE('LOC : ' || dept_rec.loc);
END;
/

//레코드를 사용한 INSERT
//DEPT_RECORD 테이블 생성하기
CREATE TABLE DEPT_RECORD
AS SELECT * FROM DEPT;
//DEPT_RECORD 테이블 생성하기(생성한 테이블 조회)
SELECT * FROM DEPT_RECORD;

//레코드를 사용하여 INSERT하기
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno NUMBER(2) NOT NULL := 99, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 99; 
   dept_rec.dname := 'DATABASE'; 
   dept_rec.loc := 'SEOUL';
INSERT INTO DEPT_RECORD VALUES dept_rec;
END;
/
//레코드 사용하여 INSERT하기(테이블 조회)
SELECT * FROM DEPT_RECORD;

//레코드를 사용한 UPDATE
//레코드를 사용하여 UPDATE하기
DECLARE 
   TYPE REC_DEPT IS RECORD( 
     deptno NUMBER(2) NOT NULL := 99, 
     dname DEPT.DNAME%TYPE, 
     loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 50; 
   dept_rec.dname := 'DB'; 
   dept_rec.loc := 'SEOUL'; 
   
   UPDATE DEPT_RECORD SET ROW = dept_rec 
   WHERE DEPTNO = 99;
END;
/
//레코드를 사용하여 UPDATE하기(테이블 조회)
SELECT * FROM DEPT_RECORD;

//레코드를 포함하는 레코트
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno DEPT.DEPTNO%TYPE, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   TYPE REC_EMP IS RECORD( 
      empno EMP.EMPNO%TYPE, 
      ename EMP.ENAME%TYPE, 
      dinfo REC_DEPT 
   ); 
   emp_rec REC_EMP;
BEGIN 
   SELECT E.EMPNO, E.ENAME, D.DEPTNO, D.DNAME, D.LOC 
   INTO emp_rec.empno, emp_rec.ename, emp_rec.dinfo.deptno,
      emp_rec.dinfo.dname, emp_rec.dinfo.loc 
   FROM EMP E, DEPT D 
   WHERE E.DEPTNO = D.DEPTNO AND E.EMPNO = 7369; 
   DBMS_OUTPUT.PUT_LINE('EMPNO : ' || emp_rec.empno); 
   DBMS_OUTPUT.PUT_LINE('ENAME : ' || emp_rec.ename); 
   DBMS_OUTPUT.PUT_LINE('DEPTNO : ' || emp_rec.dinfo.deptno); 
   DBMS_OUTPUT.PUT_LINE('DNAME : ' || emp_rec.dinfo.dname); 
   DBMS_OUTPUT.PUT_LINE('LOC : ' || emp_rec.dinfo.loc);
END;
/
SELECT * FROM EMP;

//자료형이 같은 여러 데이터를 저장하는 컬렉션
//연관배열
DECLARE 
   TYPE ITAB_EX IS TABLE OF VARCHAR2(20)
   INDEX BY PLS_INTEGER;    
   text_arr ITAB_EX;
BEGIN 
   text_arr(1) := '1st data'; 
   text_arr(2) := '2nd data'; 
   text_arr(3) := '3rd data'; 
   text_arr(4) := '4th data'; 
   DBMS_OUTPUT.PUT_LINE('text_arr(1) : ' || text_arr(1)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(2) : ' || text_arr(2)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(3) : ' || text_arr(3)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(4) : ' || text_arr(4));
END;
/

//연관 배열 자료형에 레코드 사용하기
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno DEPT.DEPTNO%TYPE,
      dname DEPT.DNAME%TYPE 
   ); 
   TYPE ITAB_DEPT IS TABLE OF REC_DEPT 
   INDEX BY PLS_INTEGER; 
   dept_arr ITAB_DEPT; 
   idx PLS_INTEGER := 0;

BEGIN 
   FOR i IN (SELECT DEPTNO, DNAME FROM DEPT) LOOP 
      idx := idx + 1; 
      dept_arr(idx).deptno := i.DEPTNO; 
      dept_arr(idx).dname := i.DNAME; 
      DBMS_OUTPUT.PUT_LINE( dept_arr(idx).deptno || ' : ' || dept_arr(idx).dname); 
   END LOOP;
END;
/

//가변 길이 배열
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');
    FOR i IN 1..5 LOOP
       DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
END;

//3번째 인덱스까지 초기화 하였으나 4번째 인덱스 접근-에러발생
//--DBMS_OUTPUT.PUT_LINE(vva_test(4)); 주석 처리하면 에러발생X
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD');
    FOR i IN 1..3
    LOOP
    DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE(vva_test(4));
END;

//중첩 테이블
DECLARE
TYPE nt_typ IS TABLE OF VARCHAR2(10);
    vnt_test nt_typ;
BEGIN
    vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD');
    FOR i IN 1..3
LOOP
    DBMS_OUTPUT.PUT_LINE(vnt_test(i));
END LOOP;
END;

//컬렉션 메서드
//자료형이 같은 여러 데이터를 저장하는 컬렉션
//컬렉션 메서드 사용하기
DECLARE 
   TYPE ITAB_EX IS TABLE OF VARCHAR2(20)
   INDEX BY PLS_INTEGER;    
   text_arr ITAB_EX;
BEGIN 
   text_arr(1) := '1st data'; 
   text_arr(2) := '2nd data'; 
   text_arr(3) := '3rd data'; 
   text_arr(50) := '50th data'; 
   DBMS_OUTPUT.PUT_LINE('text_arr.COUNT : ' || text_arr.COUNT); 
   DBMS_OUTPUT.PUT_LINE('text_arr.FIRST : ' || text_arr.FIRST); 
   DBMS_OUTPUT.PUT_LINE('text_arr.LAST : ' || text_arr.LAST); 
   DBMS_OUTPUT.PUT_LINE('text_arr.PRIOR(50) : ' || text_arr.PRIOR(50)); 
   DBMS_OUTPUT.PUT_LINE('text_arr.NEXT(50) : ' || text_arr.NEXT(50));
END;
/

//Q1.다음과 같은 결과가 나오도록 PL/SQL문을 작성
//EMP 테이블과 같은 열 구조를 가지는 빈 테이블 EMP_RECORD를 생성하는 SQL문을 작성
CREATE TABLE EMP_RECORD
    AS SELECT * 
         FROM EMP
        WHERE 1<>1;
//EMP_RECORD 테이블에 레코드를 사용하여 새로운 사원 정보를 다음과 같이 삽입하는 PL/SQL 프로그램 작성
DECLARE
   TYPE REC_EMP IS RECORD (
      empno    EMP.EMPNO%TYPE NOT NULL := 9999,
      ename    EMP.ENAME%TYPE,
      job      EMP.JOB%TYPE,
      mgr      EMP.MGR%TYPE,
      hiredate EMP.HIREDATE%TYPE,
      sal      EMP.SAL%TYPE,
      comm     EMP.COMM%TYPE,
      deptno   EMP.DEPTNO%TYPE
   );
   emp_rec REC_EMP;

BEGIN
   emp_rec.empno    := 1111;
   emp_rec.ename    := 'TEST_USER';
   emp_rec.job      := 'TEST_JOB';
   emp_rec.mgr      := null;
   emp_rec.hiredate := TO_DATE('20180301','YYYYMMDD');
   emp_rec.sal      := 3000;
   emp_rec.comm     := null;
   emp_rec.deptno   := 40;

   INSERT INTO EMP_RECORD
   VALUES emp_rec;
END;
/
SELECT * FROM EMP_RECORD;

//Q2. EMP 테이블을 구성하는 모든 열을 저장할 수 있는 레코드를 활용하여 연관 배열을 작성
//그리고 저장된 연관 배열의 내용을 다음과 같이 출력
DECLARE
   TYPE ITAB_EMP IS TABLE OF EMP%ROWTYPE
      INDEX BY PLS_INTEGER;
   emp_arr ITAB_EMP;
   idx PLS_INTEGER := 0;
BEGIN
   FOR i IN (SELECT * FROM EMP) LOOP
      idx := idx + 1;
      emp_arr(idx).empno    := i.EMPNO;
      emp_arr(idx).ename    := i.ENAME;
      emp_arr(idx).job      := i.JOB;
      emp_arr(idx).mgr      := i.MGR;
      emp_arr(idx).hiredate := i.HIREDATE;
      emp_arr(idx).sal      := i.SAL;
      emp_arr(idx).comm     := i.COMM;
      emp_arr(idx).deptno   := i.DEPTNO;

DBMS_OUTPUT.PUT_LINE(
         emp_arr(idx).empno     || ' : ' ||
         emp_arr(idx).ename     || ' : ' ||
         emp_arr(idx).job       || ' : ' ||
         emp_arr(idx).mgr       || ' : ' ||
         emp_arr(idx).hiredate  || ' : ' ||
         emp_arr(idx).sal       || ' : ' ||
         emp_arr(idx).comm      || ' : ' ||
         emp_arr(idx).deptno);

   END LOOP;
END;
/



