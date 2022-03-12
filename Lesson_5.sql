---- FUNCTION ----

/* Exercises 1.
 Write a Function with an input parameter of YEAR that needs to get data.
Calculate the total account balance (ACCOUNT) of all customers whose Year of account opening is equal to the YEAR passed in */

CREATE OR REPLACE FUNCTION SUM_AVAIL_BALANCE(YEAR IN NUMBER)
RETURN NUMBER
IS total_balance NUMBER;
BEGIN
SELECT SUM(AVAIL_BALANCE) INTO total_balance 
FROM ACCOUNT
WHERE EXTRACT(YEAR FROM OPEN_DATE) = YEAR;
RETURN total_balance;
END;
/

SELECT SUM_AVAIL_BALANCE(2004) AS TOTAL_BALANCE
FROM DUAL;
/

/* Exercises 2.
Write a Function with the input parameter of the customer's ID.
Retrieve Total number of opened accounts of customers with ID = ID passed in */

CREATE OR REPLACE FUNCTION TOTAL_ACCOUNT(ID IN NUMBER)
RETURN NUMBER
IS total_account NUMBER;
BEGIN
SELECT COUNT(*) INTO total_account
FROM ACCOUNT
WHERE CUST_ID = ID;
RETURN total_account;
END;
/

SELECT TOTAL_ACCOUNT(1) AS TOTAL_ACCOUNT
FROM DUAL;
/

/* Exercises 3.
1. Write 1 Function with the input parameter of employee ID
Implementation Calculate the number of years worked by that employee according to the following formula:
work_exp = Number of months of the current day compared to the start date of work / 12
2. Perform a query to retrieve employee information including: Full Name, Working Date, Number of Months Worked (Call the above Function) */ 

CREATE OR REPLACE FUNCTION WORK_EXP(ID IN NUMBER)
RETURN NUMBER
IS work_exp NUMBER;
BEGIN
SELECT ROUND(MONTHS_BETWEEN(SYSDATE, START_DATE) / 12) INTO work_exp
FROM EMPLOYEE
WHERE EMP_ID = ID;
RETURN work_exp;
END;
/

SELECT WORK_EXP(1) AS WORK_EXP,
        FIRST_NAME, LAST_NAME, START_DATE
FROM EMPLOYEE
WHERE EMP_ID = 1;
/

/* Exercises 4.
Write a Function "FUNC_Get_Emp_Department" with the input parameter of employee code EMP_ID and return the name of the department in which that employee works (Dept_Name).
- Requirement 1: Pass in ID 1 and display the result on the screen “Get_Emp_Department(1)”;
- Requirement 2: Write SELECT command to get all EMP_ID, First_Name, Last_Name and department name using Function “FUNC_Get_Emp_Department”. */

CREATE OR REPLACE FUNCTION FUNC_Get_Emp_Department(ID IN NUMBER)
RETURN VARCHAR2
IS dept_name VARCHAR2(30);
BEGIN
SELECT NAME INTO dept_name
FROM EMPLOYEE e, DEPARTMENT d
WHERE e.EMP_ID = ID
AND e.DEPT_ID = d.DEPT_ID;
RETURN dept_name;
END;
/

DECLARE
    emp_id NUMBER := 1;
    dept_name VARCHAR2(30);
BEGIN
    dept_name := FUNC_Get_Emp_Department(emp_id);
    dbms_output.put_line('Get_Emp_Department(' || emp_id || ') = ' || dept_name);
END;
/

SELECT EMP_ID, FIRST_NAME, LAST_NAME, FUNC_Get_Emp_Department(EMP_ID) AS DEPT_NAME
FROM EMPLOYEE e;
/

----- Procedue -----

/*Exercises 1:
Write a procedure with no parameters. Returns all information of employees including: Full name, Department, Date of employment*/

CREATE OR REPLACE PROCEDURE GET_ALL_EMPLOYEE_INFO
IS
    v_first_name EMPLOYEE.first_name%type;
    v_last_name EMPLOYEE.last_name%type;
    v_dept_name DEPARTMENT.name%type;
    v_start_date EMPLOYEE.start_date%type;
    CURSOR c_employee IS
        SELECT e.first_name, e.last_name, d.name, e.start_date
        FROM EMPLOYEE e, DEPARTMENT d
        WHERE e.dept_id = d.dept_id;
BEGIN
    OPEN c_employee;
    LOOP
    FETCH c_employee INTO v_first_name, v_last_name, v_dept_name, v_start_date;
    EXIT WHEN c_employee%NOTFOUND;
    dbms_output.put_line(v_first_name || ' ' || v_last_name || ' ' || v_dept_name || ' ' || v_start_date);
    END LOOP;
    CLOSE c_employee;
END GET_ALL_EMPLOYEE_INFO;
/

EXECUTE GET_ALL_EMPLOYEE_INFO;
/

CREATE OR REPLACE PROCEDURE GET_ALL_EMPLOYEE_INFO_2
AS
    CURSOR c_employee IS
    SELECT e.first_name, e.last_name, d.name, e.start_date
    FROM EMPLOYEE e, DEPARTMENT d
    WHERE e.dept_id = d.dept_id;
BEGIN
    FOR RECORD IN c_employee
    LOOP
    dbms_output.put_line(RECORD.first_name || ' ' || RECORD.last_name || ' ' || RECORD.name || ' ' || RECORD.start_date);
    END LOOP;
END GET_ALL_EMPLOYEE_INFO_2;
/

EXECUTE GET_ALL_EMPLOYEE_INFO_2;
/

/* Exercises 2:
Write a procedure "PRO_Get_Employee_Info" that allows to pass in the employee's ID and return the employee's First_Name, Last_Name, Dept_ID.
Hint: declare 3 variables: First_Name, Last_Name, Dept_ID to receive the OUT result from the procedure.
Run the Procedure and display the results using the DBMS_OUTPUT.PUT_LINE() statement. */

CREATE OR REPLACE PROCEDURE PRO_Get_Employee_Info(
    IN ID NUMBER,
    OUT FIRST_NAME VARCHAR2(20),
    OUT LAST_NAME VARCHAR2(20),
    OUT DEPT_ID NUMBER
)
BEGIN
    SELECT e.first_name, e.last_name, e.dept_id
    INTO FIRST_NAME, LAST_NAME, DEPT_ID
    FROM EMPLOYEE e
    WHERE e.emp_id = ID;
    dbms_output.put_line('Employee ' || FIRST_NAME );
    dbms_output.put_line('Employee ' || LAST_NAME );
    dbms_output.put_line('Employee ' || DEPT_ID );
END;
/

DECLARE
    v_first_name VARCHAR2(20);
    v_last_name VARCHAR2(20);
    v_dept_id NUMBER;
BEGIN
    PRO_Get_Employee_Info(1, v_first_name, v_last_name, v_dept_id);
    dbms_output.put_line('full name' || v_first_name || ' ' || v_last_name || 'and dept id' || v_dept_id);
END;
/

/* exercises 3:
  Write a Procedure that returns the customer segment according to each customer passed in according to the following formula:
If:
  “AVAIL_BALANCE <= 4000” then SEGMENT is: “LOW”,
“AVAIL_BALANCE > 4000 and AVAIL_BALANCE <= 7000” then SEGMENT is: “MEDIUM”, “AVAIL_BALANCE >7000” then SEGMENT is: “HIGH”
(Hint: 2 parameters: IN – customer id, OUT- segment) */

CREATE OR REPLACE PROCEDURE HIEU_GET_CUST_SEG_2(
  ID IN NUMBER,
    SEGMENT OUT VARCHAR2
)
IS
CURSOR c_cust_seg IS
    SELECT SUM(AVAIL_BALANCE) AVAIL_BALANCE,
    c.CUST_ID
    FROM ACCOUNT a
    JOIN CUSTOMER c ON a.CUST_ID = c.CUST_ID
    GROUP BY c.CUST_ID
    HAVING c.CUST_ID = ID;
BEGIN
    FOR RECORD IN c_cust_seg
    LOOP
        IF RECORD.AVAIL_BALANCE <= 4000 THEN
            SEGMENT := 'LOW';
        ELSIF RECORD.AVAIL_BALANCE > 4000 AND RECORD.AVAIL_BALANCE <= 7000 THEN
            SEGMENT := 'MEDIUM';
        ELSE
            SEGMENT := 'HIGH';
        END IF;
        dbms_output.put_line('ID: ' || RECORD.CUST_ID || ' ' || 'SEGMENT: ' || SEGMENT);
    END LOOP;
END;
/

DECLARE
    v_segment VARCHAR2(20);
BEGIN
    HIEU_GET_CUST_SEG_2(1, v_segment);
END;
/

---- BOUNUS WORK ----

/* Exercises 1: 1. Write a FUNCTION that allows 1 parameter to be passed. If the input parameter is 'EMP', get the total number of employees, if the input parameter is 'DEPT', get the total number of departments. */

CREATE OR REPLACE FUNCTION GET_TOTAL_NUMBER(
    INPUT IN VARCHAR2
)
RETURN NUMBER
IS
    v_total_number NUMBER;
BEGIN
    IF INPUT = 'EMP' THEN
        SELECT COUNT(*) INTO v_total_number
        FROM EMPLOYEE;
    ELSIF INPUT = 'DEPT' THEN
        SELECT COUNT(*) INTO v_total_number
        FROM DEPARTMENT;
    END IF;
    RETURN v_total_number;
    DBMS_OUTPUT.PUT_LINE('Total number of ' || INPUT || ' is: ' || v_total_number);
END;
/

SELECT GET_TOTAL_NUMBER('EMP')
FROM DUAL;
/

/* Exercises 2: Write a FUNCTION that allows the account ID (account_id) to be passed. Get the status of the latest transaction for that account ID according to the following request:
+ If the latest transaction >= current date, the status: 'The payment has been Completed'
+ If Latest Transaction < current date, then status: Transaction date + 'ready to be paid'
+ Remaining: 'Invalid payment' */

CREATE OR REPLACE FUNCTION GET_STATUS(
    ID IN NUMBER
)
RETURN VARCHAR2
IS
    v_status VARCHAR2(100);
    v_date DATE;
BEGIN
    SELECT MAX(CAST(FUNDS_AVAIL_DATE AS DATE)) INTO v_date
    FROM ACCOUNT
    JOIN ACC_TRANSACTION ON ACCOUNT.ACCOUNT_ID = ACC_TRANSACTION.ACCOUNT_ID
    WHERE ACCOUNT.ACCOUNT_ID = ID;
    IF v_date >= SYSDATE THEN
        v_status := 'The payment has been Completed';
    ELSIF v_date < SYSDATE THEN
        v_status := v_date || 'ready to be paid';
    ELSE
        v_status := 'Invalid payment';
    END IF;
    RETURN v_status;
    DBMS_OUTPUT.PUT_LINE('Status of the latest transaction for account id ' || ID || ' is: ' || v_status);
END;
/

SELECT GET_STATUS(1)
FROM DUAL;
/

/* Exercises 3: Write a Function that allows passing any date as a parameter. Retrieve all employees whose starting date is >= input date (Note: There are cases where the hospital employee has retired and continues to work again) */

-- first, we need to creat a record type--
CREATE OR REPLACE TYPE EMPLOYEE_RECORD AS OBJECT (
    EMPLOYEE_ID NUMBER,
    FIRST_NAME VARCHAR2(20),
    LAST_NAME VARCHAR2(20),
    START_DATE DATE
);
/

-- then, we need to create a table type --
CREATE OR REPLACE TYPE EMPLOYEE_TABLE AS TABLE OF EMPLOYEE_RECORD;
/

/* now, we are ready to create a funcion 
we can use pipeline function to get the result */

CREATE OR REPLACE FUNCTION GET_EMPLOYEE_BY_DATE(
    INPUT IN DATE
)
RETURN EMPLOYEE_TABLE
PIPELINED
IS
CURSOR c_emp_by_date IS
    SELECT DISTINCT EMPLOYEE.EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    START_DAT
    FROM EMPLOYEE
    JOIN DEPARTMENT ON EMPLOYEE.DEPT_ID = DEPARTMENT.DEPT_ID
    WHERE START_DATE >= INPUT;
BEGIN
    FOR RECORD IN c_emp_by_date
    LOOP
        PIPE ROW (EMPLOYEE_RECORD(RECORD.EMP_ID, RECORD.FIRST_NAME, RECORD.LAST_NAME, RECORD.START_DATE));
        EXIT WHEN c_emp_by_date%NOTFOUND;
    END LOOP;
    RETURN;
END;
/

-- using the function --
SELECT * FROM TABLE(GET_EMPLOYEE_BY_DATE(TO_DATE('01-01-2000', 'DD-MM-YYYY')))
/

/* Exercises 4: Write a Function that allows passing any date as a parameter. Get the total number of accounts opened by all employees as of the date of transfer and count only those employees whose number of working months up to the date of transfer is >13 months. */

CREATE OR REPLACE FUNCTION GET_TOTAL_ACCOUNT_BY_DATE(
    INPUT IN DATE
)
RETURN NUMBER
IS
    v_total_account NUMBER;
BEGIN
    SELECT COUNT(*) 
    INTO v_total_account
    FROM ACCOUNT
    JOIN EMPLOYEE ON ACCOUNT.OPEN_EMP_ID = EMPLOYEE.EMP_ID
    WHERE OPEN_DATE <= INPUT 
    AND ROUND(MONTHS_BETWEEN(SYSDATE, OPEN_DATE) / 12, 0) > 13;
    RETURN v_total_account;
END;
/

-- using the function --
SELECT GET_TOTAL_ACCOUNT_BY_DATE(TO_DATE('01-01-2020', 'DD-MM-YYYY'))
FROM DUAL;
/

/* Exercises 5
Write a Procedure that allows to pass in 2 parameters: Department code, Salary coefficient. Update salary of employees with department codes as follows:
* Use Function WORK_EXP to check if the employee has a number of years of work >= 13 or not. If it is enough, update the employee's salary (hocvien_employee table) according to CT:
New salary = old salary + old salary * salary coefficient*/

-- creat table hieu_employee with column emp_id, salary, dept_id, year_work, salary_coefficient with random data --

-- DROP TABLE HIEU_EMPLOYEE;
-- /

CREATE TABLE HIEU_EMPLOYEE 
AS (
    SELECT EMPLOYEE.EMP_ID,
    EMPLOYEE.FIRST_NAME,
    EMPLOYEE.LAST_NAME,
    DEPARTMENT.DEPT_ID,
    EMPLOYEE.START_DATE,
    CAST(DBMS_RANDOM.VALUE(50, 100) AS DECIMAL(10, 2)) AS SALARY
    FROM EMPLOYEE
    JOIN DEPARTMENT 
    ON EMPLOYEE.DEPT_ID = DEPARTMENT.DEPT_ID
);
/

CREATE OR REPLACE PROCEDURE SALARY_INCREASE(
    INPUT_DEPT_ID IN NUMBER,
    INPUT_COEFFICIENT IN NUMBER
)
IS
    year_exp NUMBER;
BEGIN
    FOR RECORD IN(
        SELECT EMPLOYEE.EMP_ID
        FROM EMPLOYEE
        WHERE DEPT_ID = INPUT_DEPT_ID
    )
    LOOP
    year_exp := WORK_EXP(RECORD.EMP_ID);
    IF year_exp >= 13 THEN
        UPDATE HIEU_EMPLOYEE
        SET SALARY = SALARY + SALARY * INPUT_COEFFICIENT
        WHERE EMP_ID = RECORD.EMP_ID;
    END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN RAISE;
END;
/

-- using the procedure --
EXECUTE SALARY_INCREASE(4000, 2);
/

/* Exercises 6
Write a Procedure that allows you to enter the name of the product or service the bank is providing and perform the following tasks:
+ Calculate the total balance according to each product and service name the bank is providing up to the current date (sysdate) (Product code, Total balance, Calculation date)
+ INSERT that data into the HOCVIEN_BC_PRODUCT table according to the corresponding information fields (Check condition: Each product can only be INSERT 1 time/1 day)*/

-- DROP TABLE HIEU_BC_PRODUCT;
-- /

CREATE TABLE HIEU_BC_PRODUCT(
    PRODUCT_NAME VARCHAR(100),
    PRODUCT_SERVICE VARCHAR(100),
    PRODUCT_CD VARCHAR(100),
    AVAIL_BALANCE NUMBER,
    CALC_DATE VARCHAR(100)
);
/

CREATE OR REPLACE PROCEDURE GET_TOTAL_BALANCE_BY_PRODUCT(
    INPUT_PRODUCT_NAME IN VARCHAR2
)
IS
CURSOR c_total_balance IS
    SELECT pt.NAME PRODUCT_NAME, p.NAME PRODUCT_SERVICE, P.PRODUCT_CD, SUM(AVAIL_BALANCE) AS AVAIL_BALANCE, TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS CALC_DATE
    FROM ACCOUNT a
    JOIN PRODUCT p
    ON a.PRODUCT_CD = p.PRODUCT_CD
    JOIN PRODUCT_TYPE pt
    ON p.PRODUCT_TYPE_CD = pt.PRODUCT_TYPE_Cd
    WHERE pt.NAME = INPUT_PRODUCT_NAME
    GROUP BY pt.NAME, p.NAME, p.PRODUCT_CD;
BEGIN
    FOR RECORD IN c_total_balance
    LOOP
        INSERT INTO HIEU_BC_PRODUCT(PRODUCT_NAME, PRODUCT_SERVICE, PRODUCT_CD, AVAIL_BALANCE, CALC_DATE)
        SELECT RECORD.PRODUCT_NAME, RECORD.PRODUCT_SERVICE, RECORD.PRODUCT_CD, RECORD.AVAIL_BALANCE, RECORD.CALC_DATE
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT *
            FROM HIEU_BC_PRODUCT
            WHERE PRODUCT_NAME = RECORD.PRODUCT_NAME
            AND PRODUCT_SERVICE = RECORD.PRODUCT_SERVICE
            AND PRODUCT_CD = RECORD.PRODUCT_CD
            AND CALC_DATE = RECORD.CALC_DATE
        );
    END LOOP;
    RETURN;
END;
/

-- using the procedure --
EXECUTE GET_TOTAL_BALANCE_BY_PRODUCT('Customer Accounts');
/

/* Exercises 7
Write a procedure without parameters to perform UPDATE/INSERT work on data in the hocvien_customer table under the following conditions:
Check if there is customer data in the customer table in the table hocvien_customer? (Compare cust_id 2 tables together)
+ If there is, then UPDATE all the data of the fields in the hocvien_customer table according to the data of the corresponding fields in the customer table.
+ If not, INSERT data into the hocvien_customer table according to the corresponding fields of the customer . table */

CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER_DATA
IS
BEGIN
MERGE INTO HIEU_CUSTOMER hc
USING CUSTOMER c
ON (hc.CUST_ID = c.CUST_ID)
WHEN MATCHED THEN
UPDATE SET
    hc.ADDRESS = c.ADDRESS,
    hc.CITY = c.CITY,
    hc.CUST_TYPE_CD = c.CUST_TYPE_CD,
    hc.FED_ID = c.FED_ID,
    hc.POSTAL_CODE = c.POSTAL_CODE,
    hc.STATE = c.STATE
WHEN NOT MATCHED THEN
INSERT (
    hc.CUST_ID, hc.ADDRESS, hc.CITY, hc.CUST_TYPE_CD, hc.FED_ID, hc.POSTAL_CODE, hc.STATE
)
VALUES (
    c.CUST_ID, c.ADDRESS, c.CITY, c.CUST_TYPE_CD, c.FED_ID, c.POSTAL_CODE, c.STATE
);
END;
/

-- using the procedure --
EXECUTE UPDATE_CUSTOMER_DATA;
/

-- DELETE FROM HIEU_CUSTOMER;
-- /

/* Exercises 8
Write a Procedure that allows passing 3 parameters: User login to the db, data type of column, value to look up. Find the total number of records of each field in each table that have the same value as the passed value. Print the results according to the following form: BANG NAME + COLLECTION NAME + TOTAL VALUE
(For example: With a CUSTOMER table with the value to be searched as '%ma%', each Column in the CUSTOMER table will have the sum of the values corresponding to the value to be searched as follows:
CUSTOMER - ADDRESS - 4
CUSTOMER - CITY - 4
) */
SET SERVEROUTPUT ON;
/

CREATE OR REPLACE PROCEDURE FIND_TOTAL_RECORDS_BY_VALUE(
    INPUT_USER_LOGIN IN VARCHAR2,
    INPUT_COLUMN_TYPE IN VARCHAR2,
    INPUT_VALUE IN VARCHAR2
)
IS
    v_count INTEGER;
BEGIN
FOR t IN (
    SELECT OWNER, TABLE_NAME, COLUMN_NAME
    FROM ALL_TAB_COLS
    WHERE OWNER = UPPER(INPUT_USER_LOGIN)
    AND DATA_TYPE LIKE UPPER('%'||INPUT_COLUMN_TYPE||'%')
)
LOOP
    EXECUTE IMMEDIATE 
    'SELECT COUNT(*) FROM '|| t.owner || '.' || t.TABLE_NAME || ' WHERE ' || t.COLUMN_NAME || ' LIKE ''%' || INPUT_VALUE || '%'''
    INTO v_count;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE(t.OWNER || ' - ' || t.TABLE_NAME || ' - ' || t.COLUMN_NAME || ' - ' || v_count);
    END IF;
END LOOP;
END FIND_TOTAL_RECORDS_BY_VALUE;
/

-- using the procedure --
EXECUTE FIND_TOTAL_RECORDS_BY_VALUE('inda02', 'cha', 's');
/