-----DATATYPE, CONTROL STATEMENT, CURSOR------

/* Exercise 1
Write a PL/SQL program that allows you to pass in 1 parameter: Employee Id. Get the employee's first_name, last_name (using the %ROWTYPE attribute).
*/

SET SERVEROUTPUT ON;
DECLARE
    v_emp_id EMPLOYEE.EMP_ID%TYPE:=1;
    v_emp_info EMPLOYEE%ROWTYPE;
BEGIN
    SELECT *
    INTO v_emp_info 
    FROM EMPLOYEE e
    WHERE e.EMP_ID = v_emp_id;
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_emp_info.FIRST_NAME || ' ' || v_emp_info.LAST_NAME);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee found with id: ' || V_emp_id);
END;
/

/* Exercise 2
Write a PL/SQL program to display detailed information of all employees including: emp_id, first_name,last_name (Using pointers).
*/

SET SERVEROUTPUT ON;
DECLARE
CURSOR c_emp_info IS
    SELECT EMP_ID, FIRST_NAME, LAST_NAME
    FROM EMPLOYEE;
BEGIN
    FOR RECORD IN c_emp_info LOOP
        DBMS_OUTPUT.PUT_LINE('Employee Id: ' || RECORD.EMP_ID);
        DBMS_OUTPUT.PUT_LINE('Employee Name: ' || RECORD.FIRST_NAME || ' ' || RECORD.LAST_NAME);
    END LOOP;
END;
/

/* Exercise 3 
Write a PL/SQL program to display detailed information of all employees including: emp_id,first_name,last_name, salary (Check if salary > 500 then return current salary.
If <500 then return the message
report: salary is less then 500). (Using pointers).
*/

SET SERVEROUTPUT ON;
DECLARE
CURSOR c_emp_info IS
    SELECT EMP_ID, FIRST_NAME, LAST_NAME, SALARY
    FROM HIEU_EMPLOYEE;
BEGIN
    FOR RECORD IN c_emp_info LOOP
        DBMS_OUTPUT.PUT_LINE('Employee Id: ' || RECORD.EMP_ID);
        DBMS_OUTPUT.PUT_LINE('Employee Name: ' || RECORD.FIRST_NAME || ' ' || RECORD.LAST_NAME);
        IF RECORD.SALARY > 500 THEN
            DBMS_OUTPUT.PUT_LINE('Employee Salary: ' || RECORD.SALARY);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Report: Salary is less then 500');
        END IF;
    END LOOP;
END;
/

/* Exercise 4
Write a PL/SQL program to display the first and last names of employees whose salary is > the average salary of the department the employee is working in (Use cursor).
*/

SET SERVEROUTPUT ON;
DECLARE
CURSOR c_emp_info IS
    SELECT e.FIRST_NAME, e.LAST_NAME, e.SALARY, e.DEPT_ID
    FROM HIEU_EMPLOYEE e
    JOIN (
        SELECT AVG(SALARY) AS AVG_SALARY, DEPT_ID
        FROM HIEU_EMPLOYEE
        GROUP BY DEPT_ID
    ) a 
    ON e.DEPT_ID = a.DEPT_ID
    WHERE e.SALARY > a.AVG_SALARY;
BEGIN
    FOR RECORD IN c_emp_info LOOP
        DBMS_OUTPUT.PUT_LINE('Employee Name: ' || RECORD.FIRST_NAME || ' ' || RECORD.LAST_NAME|| ' ' || RECORD.DEPT_ID);
    END LOOP;
END;
/
  
/* Exercise 5
Write a PL/SQL program that displays the number of employees who have started working in the company by month.
*/

SET SERVEROUTPUT ON;
DECLARE
CURSOR c_count_emp IS   
    SELECT COUNT(*) NEMBER_EMP, TO_CHAR(START_DATE, 'MM') AS MONTH
    FROM HIEU_EMPLOYEE
    GROUP BY TO_CHAR(START_DATE, 'MM')
    ORDER BY TO_CHAR(START_DATE, 'MM');
BEGIN
    FOR RECORD IN c_count_emp LOOP
        DBMS_OUTPUT.PUT_LINE('Month: ' || RECORD.MONTH || ' Number of employees: ' || RECORD.NEMBER_EMP);
    END LOOP;
END;
/

---------FUCTION --------

/* Exercise 6
Write a Function that allows converting the temperature in degrees Fahrenheit to degrees Celsius and vice versa (Passing parameters including: Temperature, scale to be converted) calculated according to the following formula:
T (° F) = T (° C) × 9/5 + 32
T (° C) = T (° F) - 32 * 5/9
*/

CREATE OR REPLACE FUNCTION CONVERT_TEMPERATURE(p_temp NUMBER, p_scale VARCHAR2)
RETURN NUMBER
IS
    v_temp NUMBER;
BEGIN
    IF p_scale = 'F' THEN
        v_temp := (p_temp - 32) * 5/9;
    ELSE
        v_temp := p_temp * 9/5 + 32;
    END IF;
    RETURN v_temp;
END;
/

-- use this function --
SELECT CONVERT_TEMPERATURE(100, 'F')
FROM DUAL;
/ 

/* Exercise 7
Write a Function that allows passing in the department name and returning a list of all employees of that department (each employee name is separated by commas).
*/

CREATE OR REPLACE FUNCTION GET_EMPLOYEE_LIST(dept_id VARCHAR2)
RETURN VARCHAR2
IS
    v_emp_list VARCHAR2(1000);
BEGIN
    SELECT LISTAGG(e.FIRST_NAME, ',') WITHIN GROUP (ORDER BY e.FIRST_NAME)
    INTO v_emp_list
    FROM EMPLOYEE e
    WHERE e.DEPT_ID = dept_id;
    RETURN v_emp_list;
END;
/

-- use this function --
SELECT GET_EMPLOYEE_LIST('1')
FROM DUAL;
/

/* Exercise 8
Write a Function that allows to pass in the account code (account_id) and check if the account opening date (open_date) is a weekend or not (Saturday, Sunday)
*/

CREATE OR REPLACE FUNCTION IS_WEEKEND(input_account_id NUMBER)
RETURN VARCHAR2
IS
    v_open_date NUMBER;
BEGIN
    SELECT TO_CHAR(OPEN_DATE, 'D')
    INTO v_open_date
    FROM ACCOUNT
    WHERE ACCOUNT_ID = 61;
    IF v_open_date = 6 OR v_open_date = 7 THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
END;
/

-- use this function --
SELECT IS_WEEKEND(61)
FROM DUAL;
/

/* Exercise 9
Write a Function that allows passing in the department code, counting the total number of employees of that department and checking if that department needs to recruit more or not. (Assume the number of employees required per room is: 30 people)
*/

CREATE OR REPLACE FUNCTION RECRUIT_MORE(dept_id NUMBER)
RETURN VARCHAR2
IS
    v_emp_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_emp_count
    FROM EMPLOYEE
    WHERE DEPT_ID = dept_id;
    IF v_emp_count < 30 THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
END;
/

-- use this function --
SELECT RECRUIT_MORE()
FROM DUAL;
/

/* Exercise 10
Write 1 Function that allows to pass in customer code, any date. Check to see how many days have passed since the date is the parameter passed in, the customer has not generated a transaction (TXN_date). If >= 50 days give a warning.
*/

CREATE OR REPLACE FUNCTION CHECK_TXN_DATE(v_cust_id NUMBER, input_date DATE)
RETURN VARCHAR2
IS
    v_days_passed NUMBER;
BEGIN
    SELECT TRUNC(input_date) - TRUNC(MAX(TXN_DATE))
    INTO v_days_passed
    FROM CUSTOMER
    JOIN ACCOUNT
    ON CUSTOMER.CUST_ID = ACCOUNT.CUST_ID
    JOIN ACC_TRANSACTION
    ON ACCOUNT.ACCOUNT_ID = ACC_TRANSACTION.ACCOUNT_ID
    WHERE CUSTOMER.CUST_ID = v_cust_id;
    IF v_days_passed >= 50 THEN
        RETURN 'WARNING';
    ELSE
        RETURN 'OK';
    END IF;
END;
/

-- use this function --
SELECT CHECK_TXN_DATE(1, TO_DATE('2003-01-01', 'YYYY-MM-DD'))
FROM DUAL;
/

----------PROCEDURE/PACKAGE/TRIGGER/MERGE -------

/* Exercise 11
Write a Procedure that allows Inserting data into emp_temp table from employee table. Print the total number of records INSERT
Use the following statement to create the target table
DROP TABLE emp_temp;
CREATE TABLE emp_temp (
  emp_id      NUMBER,
  end_date DATE
);
*/

DROP TABLE HIEU_EMP_TEMP;
/

CREATE TABLE HIEU_EMP_TEMP (
  emp_id      NUMBER,
  end_date DATE
);
/

CREATE OR REPLACE PROCEDURE INSERT_HIEU_EMP_TEMP
IS
    count_row_inserted NUMBER;
BEGIN
    INSERT INTO HIEU_EMP_TEMP
    SELECT e.EMP_ID, e.END_DATE
    FROM EMPLOYEE e;
    count_row_inserted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Total number of records inserted: ' || count_row_inserted);
    COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/

-- use this procedure --
EXECUTE INSERT_HIEU_EMP_TEMP;
/

/* Exercise 12
Using emp_temp table from lesson 11. Write a Procedure that allows to pass in employee code. Check that employee in the employee table, if that employee has quit, delete that employee in the emp_temp table. Print out the message (Using SQL%FOUND)
*/

CREATE OR REPLACE PROCEDURE DELETE_EMP_TEMP(input_emp_id NUMBER)
IS
BEGIN
    DELETE FROM HIEU_EMP_TEMP
    WHERE emp_id = input_emp_id
    AND EXISTS
    (SELECT * FROM EMPLOYEE WHERE EMP_ID = input_emp_id AND END_DATE IS NOT NULL);
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee has quit');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOT FOUND');
    END IF;
END;
/

-- use this procedure --
EXECUTE DELETE_EMP_TEMP(1);
/

/* Exercise 13
Write a Procedure that allows the transfer of client code. Check if for each customer's account, the first transaction date (funds_avail_date) is the same as the account opening date (open_date)? If so, print out the message
*/

CREATE OR REPLACE PROCEDURE CHECK_FUND_AVAIL_DATE(input_cust_id NUMBER)
IS
CURSOR c_fund_avail_date IS
    SELECT ACCOUNT.CUST_ID, ACCOUNT.ACCOUNT_ID, TRUNC(ACCOUNT.OPEN_DATE) OPEN_DATE, TRUNC(ACC_TRANSACTION.FUNDS_AVAIL_DATE) FUNDS_AVAIL_DATE
    FROM ACCOUNT
    JOIN ACC_TRANSACTION
    ON ACCOUNT.ACCOUNT_ID = ACC_TRANSACTION.ACCOUNT_ID
    WHERE ACCOUNT.CUST_ID = input_cust_id;
v_cust_id NUMBER;
v_account_id NUMBER;
v_open_date DATE;
v_funds_avail_date DATE;
BEGIN
    FOR RECORD IN c_fund_avail_date LOOP
        v_cust_id := RECORD.CUST_ID;
        v_account_id := RECORD.ACCOUNT_ID;
        v_open_date := RECORD.OPEN_DATE;
        v_funds_avail_date := RECORD.FUNDS_AVAIL_DATE;
        IF v_funds_avail_date = v_open_date THEN
            DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_cust_id || ' Account ID: ' || v_account_id || ' Funds Available Date: ' || v_funds_avail_date);
        END IF;
    END LOOP;
END;
/

-- use this procedure --
EXECUTE CHECK_FUND_AVAIL_DATE(1);
/

/* Exercise 14
Write a Procedure that allows passing 2 parameters: employee code, target level. Recalculate the employee's salary in the hocvien_customer table according to the following formula:
+ If the total number of accounts opened by that employee (total_acc_achieve) > target level + 2 (target_qty), then: New salary = old salary * (acc_achieve - target_qty)/4
+ If this target is not met, the salary will remain the same
*/

CREATE OR REPLACE PROCEDURE RECALCULATE_SALARY(input_emp_id NUMBER, input_target_qty NUMBER)
IS
    v_total_acc_achieve NUMBER;
    v_salary NUMBER;
BEGIN
    SELECT COUNT(ACCOUNT.ACCOUNT_ID), HIEU_EMPLOYEE.SALARY
    INTO v_total_acc_achieve, v_salary
    FROM ACCOUNT
    JOIN HIEU_EMPLOYEE
    ON ACCOUNT.OPEN_EMP_ID = HIEU_EMPLOYEE.EMP_ID
    WHERE HIEU_EMPLOYEE.EMP_ID = 1
    GROUP BY HIEU_EMPLOYEE.SALARY;
    IF v_total_acc_achieve > input_target_qty + 2 THEN
        v_salary := v_salary * (v_total_acc_achieve - input_target_qty)/4;
        UPDATE HIEU_EMPLOYEE
        SET SALARY = v_salary
        WHERE EMP_ID = input_emp_id;
    END IF;
END;
/

-- use this procedure --
EXECUTE RECALCULATE_SALARY(1, 3);
/

/* Exercise 15
Write a Procedure that allows INSERT/UPDATE data in table <Student Name>_EMP_LOAD according to the following requirements:
+ If that employee is already in the table: <Student Name>_EMP_LOAD. Check from the EMPLOYEE table if the employee has a date END_DATE >= START_DATE, then update the END_DATE and STATUS of the table <Student Name>_EMP_LOAD as follows:
<Student Name>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE and <Student Name>_EMP_LOAD.STATUS = 0
+ If the employee is not in the table: <Student name>_EMP_LOAD. INSERT all data from EMPLOYEE table into <Student Name>_EMP_LOAD
*/
DROP TABLE HIEU_EMP_LOAD;
/

CREATE TABLE HIEU_EMP_LOAD
AS (
    SELECT * FROM EMP_LOAD
);
/

CREATE OR REPLACE PROCEDURE INSERT_UPDATE_HIEU_EMP_LOAD
IS
BEGIN
    MERGE INTO HIEU_EMP_LOAD h
    USING (
        SELECT EMP_ID, END_DATE, FIRST_NAME, LAST_NAME, START_DATE, 
            CASE WHEN END_DATE >= START_DATE THEN 0 ELSE 1 END STATUS
        FROM EMPLOYEE
    ) e
    ON (h.EMP_ID = e.EMP_ID)
    WHEN MATCHED THEN
        UPDATE SET h.END_DATE = e.END_DATE, h.STATUS = 0
        WHERE e.END_DATE >= e.START_DATE
    WHEN NOT MATCHED THEN
        INSERT (h.EMP_ID, h.END_DATE, h.FIRST_NAME, h.LAST_NAME, h.START_DATE, h.STATUS)
        VALUES (e.EMP_ID, e.END_DATE, e.FIRST_NAME, e.LAST_NAME, e.START_DATE, e.STATUS);
END;
/

-- use this procedure --
EXECUTE INSERT_UPDATE_HIEU_EMP_LOAD;
/