---- Trigger ----

/* Exercises
Write a Package to do the following:
- 1 Cursor returns account details according to the customer ID passed in, including the following information: Customer ID, Customer Address, Account ID, Balance, Status
- 1 Function to allow input: Customer ID. Returns Total balance by customer
- 1 Function that allows input: Open employee ID + Account opening year. Returns Total balance according to the employee who opened the account
Calling pointers, functions through the newly created package */

CREATE OR REPLACE PACKAGE pkg_account_details AS
-- cursor returns account details --
CURSOR c_customer_account_details (
    customer_id IN NUMBER) 
    IS
    SELECT
        ACCOUNT.CUST_ID, CUSTOMER.ADDRESS, ACCOUNT.ACCOUNT_ID, SUM(ACCOUNT.AVAIL_BALANCE) AS BALANCE, ACCOUNT.STATUS
    FROM ACCOUNT 
    JOIN CUSTOMER
    ON ACCOUNT.CUST_ID = CUSTOMER.CUST_ID
    WHERE ACCOUNT.CUST_ID = customer_id
    GROUP BY ACCOUNT.CUST_ID, CUSTOMER.ADDRESS, ACCOUNT.ACCOUNT_ID, ACCOUNT.STATUS;

-- function returns total balance by customer --
FUNCTION f_total_balance_by_customer (customer_id IN NUMBER) 
RETURN NUMBER;

-- function returns total balance according to the employee who opened the account --
FUNCTION f_total_balance_by_employee (employee_id IN NUMBER, account_open_year IN NUMBER)
RETURN NUMBER;

END pkg_account_details;
/

CREATE OR REPLACE PACKAGE BODY pkg_account_details AS
FUNCTION f_total_balance_by_customer (customer_id IN NUMBER)
RETURN NUMBER
IS
    total_balance NUMBER;
BEGIN
    SELECT SUM(AVAIL_BALANCE) INTO total_balance
    FROM ACCOUNT
    WHERE CUST_ID = customer_id;
    RETURN total_balance;
END f_total_balance_by_customer;

FUNCTION f_total_balance_by_employee (employee_id IN NUMBER, account_open_year IN NUMBER)
RETURN NUMBER
IS
    total_balance NUMBER;
BEGIN
    SELECT SUM(AVAIL_BALANCE) INTO total_balance
    FROM ACCOUNT
    WHERE OPEN_EMP_ID = employee_id
    AND EXTRACT(YEAR FROM OPEN_DATE) = account_open_year;
    RETURN total_balance;
END f_total_balance_by_employee;

END pkg_account_details;
/

-- use this package --
SELECT pkg_account_details.f_total_balance_by_customer (1)
FROM DUAL;
/

SELECT pkg_account_details.f_total_balance_by_employee (1, 2000)
FROM DUAL;
/

SET SERVEROUTPUT ON;
DECLARE
cust_id NUMBER;
address VARCHAR2(100);
account_id NUMBER;
balance NUMBER;
status VARCHAR2(10);
BEGIN
    OPEN pkg_account_details.c_customer_account_details (1);
    FETCH pkg_account_details.c_customer_account_details INTO address, account_id, balance, status;
    DBMS_OUTPUT.PUT_LINE('Customer Address: ' || address);
    EXIT WHEN pkg_account_details.c_customer_account_details%NOTFOUND;
    CLOSE pkg_account_details.c_customer_account_details;
END;
/

/* Exercise 2:
Write a Package to do the following:
- 1 Procedure to allow input: Employee ID. Returns the last name, first name, and department code of that employee.
- 1 Function that allows input: Employee ID. Returns the name of the employee's department.
Calling Procedures and Functions through the Package just created */

CREATE OR REPLACE PACKAGE pkg_employee_details AS
-- procedure returns the last name, first name, and department code of that employee --
PROCEDURE p_employee_details (
    employee_id IN NUMBER,
    last_name OUT VARCHAR2,
    first_name OUT VARCHAR2,
    department_code OUT VARCHAR2);
-- function returns the name of the employee's department --
FUNCTION f_employee_department (employee_id IN NUMBER)
RETURN VARCHAR2;

END pkg_employee_details;
/

CREATE OR REPLACE PACKAGE BODY pkg_employee_details AS
PROCEDURE p_employee_details (
    employee_id IN NUMBER,
    last_name OUT VARCHAR2,
    first_name OUT VARCHAR2,
    department_code OUT VARCHAR2)
IS
BEGIN
    SELECT LAST_NAME, FIRST_NAME, DEPT_ID
    INTO last_name, first_name, department_code
    FROM EMPLOYEE
    WHERE EMP_ID = employee_id;
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || first_name || ' ' || last_name);
    DBMS_OUTPUT.PUT_LINE('Employee Department: ' || department_code);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
END;        

FUNCTION f_employee_department (employee_id IN NUMBER)
RETURN VARCHAR2
IS
department_name VARCHAR2(100);
BEGIN
    SELECT d.NAME INTO department_name
    FROM DEPARTMENT d
    JOIN EMPLOYEE e
    ON d.DEPT_ID = e.DEPT_ID
    WHERE EMP_ID = employee_id;
    RETURN department_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    department_name := 'No data found';
END;
END pkg_employee_details;
/

-- use this package --
SET SERVEROUTPUT ON;
DECLARE
employee_id NUMBER:= 1;
last_name VARCHAR2(100);
first_name VARCHAR2(100);
department_code VARCHAR2(10);
v_department_name VARCHAR2(100);
BEGIN
    pkg_employee_details.p_employee_details (employee_id, last_name, first_name, department_code);
    v_department_name := pkg_employee_details.f_employee_department (employee_id);
    DBMS_OUTPUT.PUT_LINE('Employee Department Name: ' || v_department_name);
END;
/


-------- TRIGGER--------

/* Exercise 1:
Create a Trigger that allows backing up all the changes of the EMPLOYEE table (Insert the change data of the fields corresponding to the EMPLOYEE table into the EMPLOYEE_BACKUP, CHANGE_DATE = SYSDATE table) */

--- create backup table ---
DROP TABLE HIEU_EMPLOYEE_BACKUP;
/

CREATE TABLE HIEU_EMPLOYEE_BACKUP
(
    EMP_ID NUMBER,
    END_DATE DATE,
    FIRST_NAME VARCHAR2(100),
    LAST_NAME VARCHAR2(100),
    START_DATE DATE,
    TITLE VARCHAR2(100),
    ASSIGNED_BRANCH_ID NUMBER,
    DEPT_ID NUMBER,
    SUPERIOR_EMP_ID NUMBER,
    CHANGE_DATE DATE
);
/

--- create trigger backup the table ---
CREATE OR REPLACE TRIGGER HIEU_EMPLOYEE_BACKUP_TRIGGER
BEFORE UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    INSERT INTO HIEU_EMPLOYEE_BACKUP
    (
        EMP_ID,
        END_DATE,
        FIRST_NAME,
        LAST_NAME,
        START_DATE,
        TITLE,
        ASSIGNED_BRANCH_ID,
        DEPT_ID,
        SUPERIOR_EMP_ID,
        CHANGE_DATE
    )
    VALUES
    (
        :OLD.EMP_ID,
        :OLD.END_DATE,
        :OLD.FIRST_NAME,
        :OLD.LAST_NAME,
        :OLD.START_DATE,
        :OLD.TITLE,
        :OLD.ASSIGNED_BRANCH_ID,
        :OLD.DEPT_ID,
        :OLD.SUPERIOR_EMP_ID,
        SYSDATE
    );
END;
/

/* Exercise 2:
Create a Trigger that allows updating the state of 2 fields: Updated_date = sysdate, Updated_by = User when there is a change to the ETL_CUSTOMER table */

CREATE OR REPLACE TRIGGER HIEU_CUSTOMER_TRIGGER
AFTER UPDATE ON ETL_CUSTOMER
FOR EACH ROW
BEGIN
    UPDATE ETL_CUSTOMER
    SET
    UPDATED_DATE = SYSDATE,
    UPDATED_BY = USER
    WHERE CUST_ID = :OLD.CUST_ID;
END;
/

/* Exercise 3:
Write 1 Trigger that  allows automatic Bonus for managers 10% of salary of new employees
Hint: When a new employee is added to the database. Insert adds a new record to the BONUS table with (management employee ID, 10% corresponding salary)*/

-- create table salary bouns --


-- create trigger to insert salary bonus --
CREATE OR REPLACE TRIGGER HIEU_SALARY_BONUS_TRIGGER
AFTER INSERT ON EMPLOYEE
FOR EACH ROW
DECLARE
    v_salary NUMBER;
BEGIN
    IF :NEW.SAL IS NOT NULL THEN
        v_salary := :NEW.SAL*0.1;
        INSERT INTO BONUS
        (
            EMP_ID,
            SALARY
        )
        VALUES
        (
            :NEW.MGR,
            v_salary
        );
    END IF;
END;
/