//�Ķ���͸� ������� �ʴ� ���ν���
CREATE OR REPLACE PROCEDURE PROC
AS
V_EMPNO NUMBER(4) := 1234;
BEGIN
DBMS_OUTPUT.PUT_LINE('V_EMPNO : ' || V_EMPNO);
END;
/
//���ν��� PROC�� �׽�Ʈ�ϴ� �κ�
SET SERVEROUTPUT ON ;
  exec proc;

//���ν��� ���࿡ �ʿ��� ���� ���� �Է� �޴� ����
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
//���ν��� PROC�� �׽�Ʈ�ϴ� �κ�
BEGIN 
	PROC_PARAMS(1,2);
END;

//���ν��� ���� �� ȣ���� ���α׷����� ���� ��ȯ ���� �� �ִ� ���
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
//���ν��� PROC�� �׽�Ʈ�ϴ� �κ�
DECLARE
	param1 NUMBER;
BEGIN
	PROC_OUT(param1);
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
END;

//Ʈ����
//�����ͺ��̽� ���� Ư�� ��Ȳ�̳� ����(�̺�Ʈ)�� �߻��� ��� �ڵ����� ����Ǵ� ����� ���� �������α׷�
//Ʈ���Ŵ� �������� ���湮�� ����� �� �ڵ����� ���� ����Ǵ� ���ν����� ���Ѵ�
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

insert into emp (empno, ename) values (88, '88�浿');
select * from emp;
update emp set sal = sal + 10 where empno = 7369;
update emp set ename = '������' where empno = 7369;

//��Ʈ���� ����
//���̺� ����
create table emp_bak (
     old_sal number,
     new_sal number,
     u_date date,
     action varchar2(20));

select * from emp_bak;
//Ʈ���� ����
create or replace trigger tr_emp_update
      after update of sal on emp
      for each row
begin
      insert into emp_bak values (:old.sal, :new.sal, sysdate,'UPDATE');
end;
/
//emp ���̺� ������Ʈ
update emp set sal = sal + 500;

select * from emp_bak;

//WHEN���� �̿��Ͽ� ������ �´� ��쿡�� Ʈ���Ű� �����ϵ��� �� �� �ִ�
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
      dbms_output.put_line(',�޿����� ' || sal_diff); 
END; 
/ 
update emp set sal = 0; 
select * from emp;
rollback;
select * from emp;
update emp set sal = 501; 

//�ڷ����� �ٸ� ���� �����͸� �����ϴ� ���ڵ�
//���ڵ� �����ؼ� ����ϱ�
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

//���ڵ带 ����� INSERT
//DEPT_RECORD ���̺� �����ϱ�
CREATE TABLE DEPT_RECORD
AS SELECT * FROM DEPT;
//DEPT_RECORD ���̺� �����ϱ�(������ ���̺� ��ȸ)
SELECT * FROM DEPT_RECORD;

//���ڵ带 ����Ͽ� INSERT�ϱ�
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
//���ڵ� ����Ͽ� INSERT�ϱ�(���̺� ��ȸ)
SELECT * FROM DEPT_RECORD;

//���ڵ带 ����� UPDATE
//���ڵ带 ����Ͽ� UPDATE�ϱ�
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
//���ڵ带 ����Ͽ� UPDATE�ϱ�(���̺� ��ȸ)
SELECT * FROM DEPT_RECORD;

//���ڵ带 �����ϴ� ����Ʈ
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

//�ڷ����� ���� ���� �����͸� �����ϴ� �÷���
//�����迭
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

//���� �迭 �ڷ����� ���ڵ� ����ϱ�
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

//���� ���� �迭
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');
    FOR i IN 1..5 LOOP
       DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
END;

//3��° �ε������� �ʱ�ȭ �Ͽ����� 4��° �ε��� ����-�����߻�
//--DBMS_OUTPUT.PUT_LINE(vva_test(4)); �ּ� ó���ϸ� �����߻�X
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

//��ø ���̺�
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

//�÷��� �޼���
//�ڷ����� ���� ���� �����͸� �����ϴ� �÷���
//�÷��� �޼��� ����ϱ�
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

//Q1.������ ���� ����� �������� PL/SQL���� �ۼ�
//EMP ���̺�� ���� �� ������ ������ �� ���̺� EMP_RECORD�� �����ϴ� SQL���� �ۼ�
CREATE TABLE EMP_RECORD
    AS SELECT * 
         FROM EMP
        WHERE 1<>1;
//EMP_RECORD ���̺� ���ڵ带 ����Ͽ� ���ο� ��� ������ ������ ���� �����ϴ� PL/SQL ���α׷� �ۼ�
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

//Q2. EMP ���̺��� �����ϴ� ��� ���� ������ �� �ִ� ���ڵ带 Ȱ���Ͽ� ���� �迭�� �ۼ�
//�׸��� ����� ���� �迭�� ������ ������ ���� ���
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



