
-------------- PL/SQL BASIC COMMANDS ---------------------

/* Exercises 1: Use the IF-ELSE loop to perform the following request: Check the customer's account balance with ID = 1.
If the account balance is > $1000, print the message "Your current balance is currently greater than $1000",
otherwise print the message "Your current balance does not reach $1000" (ACCOUNT table).
Display the screen with the command: dbms_output.put_line() */

SET SERVEROUTPUT ON
DECLARE
  v_total_balance NUMBER;
BEGIN
    SELECT SUM(AVAIL_BALANCE)
    INTO v_total_balance
    FROM ACCOUNT 
    WHERE CUST_ID = 1;
    IF v_total_balance > 1000 THEN
        dbms_output.put_line('Your current balance is currently greater than $1000');
    ELSE
        dbms_output.put_line('Your current balance does not reach $1000');
    END IF;
END;
/

/* Exercises 2: Use FOR..LOOP to retrieve the following information: ID: Department id and Department name ”. (Department Table)
Display the screen with the command: dbms_output.put_line() */ 
SET SERVEROUTPUT ON
BEGIN
    FOR r IN (SELECT DEPT_ID, NAME
                FROM DEPARTMENT)
    LOOP

        dbms_output.put_line('ID: ' || r.DEPT_ID || ' Department name: ' || r.NAME);
    END LOOP;
END;
/

/* Exercises 3:  use for loop to get information: amount of 10 days from 25-01-2004 from Acc_transaction table
Display the screen with the command: dbms_output.put_line() */

SET SERVEROUTPUT ON
DECLARE
    v_start_date DATE := TO_DATE('25-01-2004', 'DD-MM-YYYY');
    v_amount NUMBER;
    v_date DATE;
BEGIN
    FOR r IN 0..9
    LOOP
        BEGIN
        v_date := v_start_date + r;
        SELECT AMOUNT
        INTO v_amount
        FROM ACC_TRANSACTION
        WHERE TXN_DATE = v_date;
        dbms_output.put_line('Amount of the day ' || v_date || ' is ' || v_amount);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('No data found');
        END;
    END LOOP;
END;
/


/* Exercises 4: Using WHILE..FOR to get the information: Amount of all transactions starting from 24/01-2004 until 02-28-2014 .(Table Acc_transaction )
Display the screen with the command: dbms_output.put_line() */ 
SET SERVEROUTPUT ON
DECLARE
  v_amount NUMBER;
  v_date DATE;
  v_start_date DATE := DATE '2004-01-24';
  v_end_date DATE := DATE '2004-02-28';
BEGIN
  v_date := v_start_date;
  WHILE v_date <= v_end_date
  LOOP
    BEGIN
     SELECT AMOUNT
     INTO v_amount
     FROM ACC_TRANSACTION
     WHERE TXN_DATE = v_date;
     dbms_output.put_line('Amount of the day ' || v_date || ' is ' || v_amount);
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('No data found for the day'|| v_date);
    END;
    v_date := v_date + 1;
  END LOOP;
END;
/


-------------- CURSOR ---------------------

/* Exercises 1: Use the cursor to get the information: Product code (product_cd), Product package name (name) that the bank is providing (Product table).
And display the screen with the command: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_product IS
    SELECT product_cd, name
    FROM product;
BEGIN
    FOR r IN c_product
    LOOP
        dbms_output.put_line('Product code: ' || r.product_cd || ' Product package name: ' || r.name);
    END LOOP;
END;
/

/* Exercises 2: Use an explicit cursor to retrieve information including Customer ID and product name that Customer uses, from the Account and Product table (account join Product on account .Product_CD = Product.Product_CD)
And display the results on the screen "Cust_ID,Product Name" with the command: dbms_output.put_line()*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_account IS
    SELECT account.CUST_ID, product.name
    FROM account
    JOIN product
    ON account.PRODUCT_CD = product.product_cd;
 v_cursor c_account%ROWTYPE;
BEGIN
    OPEN c_account;
    LOOP
        FETCH c_account INTO v_cursor;
        EXIT WHEN c_account%NOTFOUND;
        dbms_output.put_line('Cust_ID: ' || v_cursor.CUST_ID || ' Product Name: ' || v_cursor.name);
    END LOOP;
    CLOSE c_account;
END;
/

/*Exercises 3: Use explicit cursor cursor to retrieve information including: “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT” of all customers.
If:
  “AVAIL_BALANCE <= 4000” then SEGMENT is: “LOW”,
“AVAIL_BALANCE > 4000 and AVAIL_BALANCE <= 7000” then SEGMENT is: “MEDIUM”,

“AVAIL_BALANCE > 7000” then SEGMENT is: “HIGH”
Then display the results: “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT” to the screen with the command dbms_output.put_line().
Hint: Using data from the following tables: Customer, Account, Individual), hints:
  account join customer on customer.cust_id = account.cust_id
join individual on individual.cust_id = customer.cust_id*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_customer IS
    SELECT individual.FIRST_NAME, individual.LAST_NAME, account.AVAIL_BALANCE, 
    CASE
      WHEN account.AVAIL_BALANCE <= 4000 THEN 'LOW'
      WHEN account.AVAIL_BALANCE > 4000 AND account.AVAIL_BALANCE <= 7000 THEN 'MEDIUM'
      WHEN account.AVAIL_BALANCE > 7000 THEN 'HIGH'
    END AS SEGMENT
    FROM customer
    JOIN account
    ON customer.cust_id = account.cust_id
    JOIN individual
    ON individual.cust_id = customer.cust_id;
 v_cursor c_customer%ROWTYPE;
BEGIN
    OPEN c_customer;
    LOOP
        FETCH c_customer INTO v_cursor;
        EXIT WHEN c_customer%NOTFOUND;
        dbms_output.put_line( v_cursor.FIRST_NAME ||v_cursor.LAST_NAME || ' AVAIL_BALANCE: ' || v_cursor.AVAIL_BALANCE || ' SEGMENT: ' || v_cursor.SEGMENT);
    END LOOP;
    CLOSE c_customer;
END;
/


/* Exercises 4: Using an explicit cursor to retrieve information including Customer Code and product name that Customer uses, taken from the Account and Product table (account join Product on account .Product_CD = Product.Product_CD)
And display the results on the screen “Cust_ID,Product Name” with the command: dbms_output.put_line() */
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_account IS
    SELECT account.CUST_ID, product.NAME
    FROM account
    JOIN product
    ON account.Product_CD = product.Product_CD;
  v_cursor c_account%ROWTYPE;
BEGIN
  FOR v_cursor IN c_account
  LOOP
    dbms_output.put_line(v_cursor.CUST_ID || ' ' || v_cursor.NAME);
  END LOOP;    
END;
/


/* Exercises 5: Create table ETL_CUSTOMER according to the following sample code:
CREATE TABLE ETL_CUSTOMER(
cust_id NUMBER,
segment VARCHAR2(50) NOT NULL,
etl_date date NOT NULL
);
+ Do the same exercise 3 to calculate the SEGMENT of each customer. Then Insert data into the ETL_CUSTOMER table with the following fields:
- cust_id = ID_CLICK CUSTOMER,
- segment = SEGMENT,
- elt_date = Current date (Data added date)
 
+ Print to the screen with the command dbms_output.put_line() the following information: Total number of records added + Total running time
  (Hint: Use data from the following tables: Customer, Account, Individual)*/

-- Create a new relational table with 3 columns

CREATE TABLE HIEU_ETL_CUSTOMER(
  cust_id NUMBER,
  segment VARCHAR2(50) NOT NULL,
  etl_date date NOT NULL
  );
/

SET SERVEROUTPUT ON
DECLARE
  CURSOR c_customer IS
    SELECT customer.cust_id,
    CASE
      WHEN SUM(AVAIL_BALANCE) <= 4000 THEN 'LOW'
      WHEN SUM(AVAIL_BALANCE) > 4000 AND SUM(AVAIL_BALANCE) <= 7000 THEN 'MEDIUM'
      WHEN SUM(AVAIL_BALANCE) > 7000 THEN 'HIGH'
    END AS SEGMENT
    FROM customer
    JOIN account
    ON customer.cust_id = account.cust_id
    JOIN individual
    ON individual.cust_id = customer.cust_id
    GROUP BY customer.cust_id
    ORDER BY customer.cust_id;
    v_cursor c_customer%ROWTYPE;
    count_record NUMBER;
BEGIN
    FOR v_cursor IN c_customer
    LOOP
      INSERT INTO HIEU_ETL_CUSTOMER(cust_id, segment, etl_date)
      VALUES(v_cursor.cust_id, v_cursor.segment, SYSDATE);
    END LOOP;

    SELECT COUNT(*) INTO count_record 
    FROM HIEU_ETL_CUSTOMER;

    dbms_Output.Put_Line('Total number of records added: ' || count_record);
    dbms_output.put_line('Total running time: ' || SYSTIMESTAMP);
END;
/

DELETE FROM HIEU_ETL_CUSTOMER
/

/*Bonus work:*/
/*Exercises 1:
Use the loop to get the information: ID: Employee ID, Employee's Full Name, Department ID, Office Name of employees with branch code = 1. (Join 2 tables Employee and Department)
Display the screen with the command: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_employee (BRANCH_CODE NUMBER) IS
    SELECT e.emp_id,
    e.first_name || ' ' || e.last_name full_name,
    e.dept_id,
    d.name
    FROM employee e
    JOIN department d
    ON e.dept_id = d.dept_id
    WHERE e.assigned_branch_id = BRANCH_CODE;
    v_cursor c_employee%ROWTYPE;
BEGIN
    FOR v_cursor IN c_employee(1)
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_cursor.emp_id || ' - Name: ' || v_cursor.full_name || ' - Dept ID: ' || v_cursor.dept_id || ' - Dept Name: ' || v_cursor.name);
    END LOOP;
END;
/


/* Exercises 2:
Using a loop to get information: Total number of accounts opened by employee with ID = 10
If:
  “Total number of accounts opened <= 1”, then Level is: “LOW”,
“Total opened accounts > 2 and Total opened accounts <= 4”, then Level is: “Avg”,
“Total opened accounts > 4 and Total opened accounts <= 6”, then Level is: “Moderate”,
In the other case, Level is: “Hight”
Then display the Level result on the screen with the dbms_output.put_line() command.*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_employee (EMP_ID NUMBER) IS
    SELECT COUNT(*) total_acc
    FROM account
    WHERE open_emp_id = EMP_ID;
  v_cursor c_employee%ROWTYPE;
BEGIN
    FOR v_cursor IN c_employee(10)
    LOOP
        IF v_cursor.total_acc <= 1 THEN
            DBMS_OUTPUT.PUT_LINE('Level: LOW');
        ELSIF v_cursor.total_acc > 1 and v_cursor.total_acc <= 4 THEN
            DBMS_OUTPUT.PUT_LINE('Level: Avg');
        ELSIF v_cursor.total_acc > 4 and v_cursor.total_acc <= 6 THEN
            DBMS_OUTPUT.PUT_LINE('Level: Moderate');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Level: Hight');
        END IF;
    END LOOP;
END;
/

/*Exercises 3:
Use a loop to get the total number of accounts of 2000, 2001, 2002, 2003, 2004, 2005
Display the screen with the command: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_account IS
    SELECT COUNT(*) total_acc, EXTRACT(YEAR FROM open_date) year
    FROM account
    GROUP BY EXTRACT(YEAR FROM open_date)
    ORDER BY year;
  v_cursor c_account%ROWTYPE;
  start_year NUMBER := 2000;
  end_year NUMBER := 2005;
BEGIN
    FOR v_cursor IN c_account
    LOOP
        IF v_cursor.year >= start_year and v_cursor.year <= end_year THEN
            DBMS_OUTPUT.PUT_LINE('Year: ' || v_cursor.year || ' - Total: ' || v_cursor.total_acc);
        END IF;
    END LOOP;
END;
/


/*Exercises 4: Use the cursor to get a report including: Employee code, employee's first and last name and the first date that employee opened an account for a customer (Hint: use 2 Employee tables and Tables). Account)
Display the screen with the command: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_employee IS
    SELECT e.emp_id,
           e.first_name||' '||e.last_name full_name,
           MIN(a.open_date) first_date
    FROM employee e
    JOIN account a
      ON e.emp_id = a.open_emp_id
    GROUP BY e.emp_id,
             e.first_name,
             e.last_name
    ORDER BY e.emp_id;
  v_cursor c_employee%ROWTYPE;
BEGIN
    FOR v_cursor IN c_employee
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_cursor.emp_id || ' - Name: ' || v_cursor.full_name || ' - First Date: ' || v_cursor.first_date);
    END LOOP;
END;
/


/* Exercises 5: Use the cursor to get a report including: Employee ID, employee's first and last name, starting date of work and the amount of bonus earned according to work experience
The bonus amount is calculated according to the following CT:
+ Working time = Number of months of the current day compared to the date of starting work / 12
+ If working time > 13: Bonus = 8000
+ If working time > 11: Bonus = 5000
+ If working time > 9: Bonus = 3000
+ If working time > 7: Bonus = 2000
+ If working time > 4: Bonus = 1000
Display the screen with the command: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE
  CURSOR c_employee IS
    SELECT e.emp_id,
           e.first_name||' '||e.last_name full_name,
           e.start_date
    FROM employee e
    ORDER BY e.emp_id;
  v_cursor c_employee%ROWTYPE;
  v_bonus NUMBER;
  v_working_time NUMBER;
BEGIN
    FOR v_cursor IN c_employee
    LOOP
        v_working_time := MONTHS_BETWEEN(SYSDATE, v_cursor.start_date) / 12;
        IF v_working_time > 13 THEN
            v_bonus := 8000;
        ELSIF v_working_time > 11 THEN
            v_bonus := 5000;
        ELSIF v_working_time > 9 THEN
            v_bonus := 3000;
        ELSIF v_working_time > 7 THEN
            v_bonus := 2000;
        ELSIF v_working_time > 4 THEN
            v_bonus := 1000;
        ELSE
            v_bonus := 0;
        END IF;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_cursor.emp_id || ' - Name: ' || v_cursor.full_name || ' - Start Date: ' || v_cursor.start_date || ' - Bonus: ' || v_bonus);
    END LOOP;
END;
/
