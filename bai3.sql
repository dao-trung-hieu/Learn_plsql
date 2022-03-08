/* Exercises 1: We have 2 tables: CUSTOMER and HOCVIEN_CUSTOMER
Use the MERGE command to modify the HOCVIEN_CUSTOMER table based on changes to the CUSTOMER table
+ If the CUST_TYPE_CD field data of the CUSTOMER table is different from the CUST_TYPE_CD field of the HOCVIEN_CUSTOMER table, then UPDATE: HOCVIEN_CUSTOMER.CUST_TYPE_CD = CUSTOMER .CUST_TYPE_CD
+ If there is no matching data between 2 tables, INSERT all data from CUSTOMER table into HOCVIEN_CUSTOMER*/

CREATE TABLE HIEU_CUSTOMER AS
SELECT * FROM HOCVIEN_CUSTOMER;
/

MERGE INTO HIEU_CUSTOMER ds
USING CUSTOMER st 
ON (ds.CUST_ID = st.CUST_ID)
WHEN MATCHED THEN
    UPDATE SET ds.CUST_TYPE_CD = st.CUST_TYPE_CD
    WHERE ds.CUST_TYPE_CD <> st.CUST_TYPE_CD
WHEN NOT MATCHED THEN
    INSERT (ds.CUST_ID, ds.ADDRESS, ds.CITY, ds.CUST_TYPE_CD, ds.FED_ID, ds.POSTAL_CODE, ds.STATE)
    VALUES (st.CUST_ID, st.ADDRESS, st.CITY, st.CUST_TYPE_CD, st.FED_ID, st.POSTAL_CODE, st.STATE);
/

/* Exercises 2: Write a command to get the name of the product packages and the total balance for each product that the bank is providing (using product table join account table). Use ROW_NUMBER() to sort product bundles by total balance in descending order*/

SELECT p.NAME, SUM(a.AVAIL_BALANCE) AS TOTAL_BALANCE,
ROW_NUMBER() OVER (ORDER BY SUM(a.AVAIL_BALANCE) DESC) RANK
FROM PRODUCT p
JOIN ACCOUNT a ON p.PRODUCT_CD = a.PRODUCT_CD
GROUP BY p.NAME;
/

/* Exercises 3: Write a command to get the name of the product packages and the total balance for each product that the bank is providing. Use DENSE_RANK() to sort product bundles by total balance in descending order*/

SELECT p.NAME, SUM(a.AVAIL_BALANCE) AS TOTAL_BALANCE,
DENSE_RANK() OVER (ORDER BY SUM(a.AVAIL_BALANCE) DESC) RANK
FROM PRODUCT p
JOIN ACCOUNT a ON p.PRODUCT_CD = a.PRODUCT_CD
GROUP BY p.NAME;
/

/* Exercises 4: Write a command to get the name of the product packages and the total balance for each product that the bank is providing. Use RANK() to sort product bundles by total balance in descending order*/

SELECT p.NAME, SUM(a.AVAIL_BALANCE) AS TOTAL_BALANCE,
RANK() OVER (ORDER BY SUM(a.AVAIL_BALANCE) DESC) RANK
FROM PRODUCT p
JOIN ACCOUNT a ON p.PRODUCT_CD = a.PRODUCT_CD
GROUP BY p.NAME;
/

/* Exercises 5: Calculate the total transaction value by year, compare the current year with the previous year
 
+ Step 1: Calculate total transactions by year
+ Step 2: Use the LAG function to return the total transactions compared to the previous year */

SELECT EXTRACT(YEAR FROM TXN_DATE) year,
        SUM(AMOUNT) AS total_transaction,
        LAG(SUM(AMOUNT), 1) OVER (ORDER BY EXTRACT(YEAR FROM TXN_DATE) DESC) AS total_transaction_previous_year
FROM ACC_TRANSACTION
GROUP BY EXTRACT(YEAR FROM TXN_DATE);
/

/* Exercises 6: Calculate the total transaction value of each branch for each year. Compare the value of that year with the next year
+ Step 1: Calculate total transactions by year
+ Step 2: Use the LEAD function to return the total transaction compared to the following year*/

SELECT BRANCH.NAME,
        EXTRACT(YEAR FROM TXN_DATE) year,
        SUM(AMOUNT) AS total_transaction,
        LEAD(SUM(AMOUNT), 1) OVER (PARTITION BY BRANCH.NAME 
        ORDER BY EXTRACT(YEAR FROM TXN_DATE)) AS total_transaction_next_year 
FROM ACC_TRANSACTION
JOIN ACCOUNT
ON ACC_TRANSACTION.ACCOUNT_ID = ACCOUNT.ACCOUNT_ID
JOIN BRANCH
ON ACCOUNT.OPEN_BRANCH_ID = BRANCH.BRANCH_ID
GROUP BY BRANCH.NAME, EXTRACT(YEAR FROM TXN_DATE)
ORDER BY BRANCH.NAME, EXTRACT(YEAR FROM TXN_DATE);
/

/* Lesson 7: Calculate the total transaction value of each branch for each year. Compare that year's value to the next year and calculate the % change
 
+ Step 1: Calculate total transactions by year
+ Step 2: Use the LAD function to return the total transaction compared to the following year */

SELECT BRANCH.NAME,
        EXTRACT(YEAR FROM TXN_DATE) year,
        SUM(AMOUNT) AS total_transaction,
        LEAD(SUM(AMOUNT), 1) OVER (PARTITION BY BRANCH.NAME 
        ORDER BY EXTRACT(YEAR FROM TXN_DATE)) AS total_transaction_next_year,
        (LEAD(SUM(AMOUNT), 1) OVER (PARTITION BY BRANCH.NAME
        ORDER BY EXTRACT(YEAR FROM TXN_DATE)) - SUM(AMOUNT)) / SUM(AMOUNT) * 100 AS percent_change
FROM ACC_TRANSACTION
JOIN ACCOUNT
ON ACC_TRANSACTION.ACCOUNT_ID = ACCOUNT.ACCOUNT_ID
JOIN BRANCH
ON ACCOUNT.OPEN_BRANCH_ID = BRANCH.BRANCH_ID
GROUP BY BRANCH.NAME, EXTRACT(YEAR FROM TXN_DATE)
ORDER BY BRANCH.NAME, EXTRACT(YEAR FROM TXN_DATE);
/

----BonusWork----
/* Exercises 1:
Creat new EMP_LOAD table have structure like EMPLOYEE table with  random data from EMPLOYEE table to EMP_LOAD table */

CREAT TABLE HIEU_EMP_LOAD AS
SELECT *
FROM EMP_LOAD;
/

MERGE INTO HIEU_EMP_LOAD h_emp
USING (
        SELECT e.EMP_ID, e.END_DATE, e.FIRST_NAME, e.LAST_NAME, e.START_DATE, 
               CASE WHEN e.END_DATE >= e.START_DATE THEN '0' ELSE '1' END AS STATUS
        FROM EMPLOYEE e
) emp
ON (h_emp.EMP_ID = emp.EMP_ID)
WHEN MATCHED THEN
UPDATE SET h_emp.END_DATE = emp.END_DATE, h_emp.STATUS = emp.STATUS
WHERE h_emp.END_DATE < emp.END_DATE;
WHEN NOT MATCHED THEN
INSERT (h_emp.EMP_ID, h_emp.END_DATE, h_emp.FIRST_NAME, h_emp.LAST_NAME, h_emp.START_DATE, h_emp.STATUS)
VALUES (emp.EMP_ID, emp.END_DATE, emp.FIRST_NAME, emp.LAST_NAME, emp.START_DATE, emp.STATUS);
/

/* Exercises Create a table <Student Name>_CUST_LOAD taken from the CUST_LOAD table. Use Merge to rank customers (RANK_TRANS) of table <Student Name>_CUST_LOAD according to the following instructions:
1. Use the ranking function to rank customers according to the total number of transactions (customers with the same total number of transactions will be of the same rank).
2. Update the rank (RANK_TRANS) of the table <Student Name>_CUST_LOAD according to the Rank calculated in step 1 if their Rank is different
3. Add all the data calculated from step 1 to the table <Student Name>_CUST_LOAD if that customer has not been ranked on that day
* Assume: Every day will have to calculate the customer's Rank 1 time. Think of a way to only allow updates or new additions to the table <Student Name>_CUST_LOAD 1 time / day*/

CREATE TABLE HIEU_CUST_LOAD AS
SELECT *
FROM CUST_LOAD;
/

MERGE INTO HIEU_CUST_LOAD h_cust
USING (
        SELECT c.CUST_ID, COUNT(*) AS total_transaction,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS RANK_TRANS
        TRUNC(SYSDATE) AS UPDATE_DATE
        FROM CUSTOMER c
        JOIN ACCOUNT a
        ON c.CUST_ID = a.CUST_ID
        JOIN ACC_TRANSACTION acc
        ON acc.ACCOUNT_ID = a.ACCOUNT_ID
        GROUP BY c.CUST_ID, TRUNC(SYSDATE)
        ) cust
ON (h_cust.CUST_ID = cust.CUST_ID AND h_cust.UPDATE_DATE = cust.UPDATE_DATE)
WHEN MATCHED THEN
UPDATE SET h_cust.RANK_TRANS
WHERE h_cust.RANK_TRANS <> c.RANK_TRANS
WHEN NOT MATCHED THEN
INSERT (h_cust.CUST_ID, h_hust.RANK_TRANS, h_cust.UPDATE_DATE)
VALUES (c.CUST_ID, c.RANK_TRANS, c.UPDATE_DATE);
/

/* Exercises 3: Write a statement to get the total balance of each customer's account. Use the Ranking Function to rank each customer's account by account balance. Get the top 1 and 2 of each account */

SELECT * FROM
(SELECT CUSTOMER.CUST_ID, ACCOUNT.ACCOUNT_ID, SUM(ACCOUNT.AVAIL_BALANCE) AS total_balance,
        ROW_NUMBER() OVER (PARTITION BY CUSTOMER.CUST_ID ORDER BY SUM(ACCOUNT.AVAIL_BALANCE) DESC) AS rank
FROM CUSTOMER
JOIN ACCOUNT
ON CUSTOMER.CUST_ID = ACCOUNT.CUST_ID
GROUP BY CUSTOMER.CUST_ID, ACCOUNT.ACCOUNT_ID)
WHERE rank <= 2;
/

/* Exercises 4: Calculating total account balance (AVAIL_BALANCE) for each year and products and services of the bank. Only product accounts opened between 2000 and 2003 (OPEN_DATE). Compare with previous year and calculate % change*/

SELECT p.YEAR, p.NAME, p.PREV_YEAR_SALES,
        NVL(ROUND((p.YEAR_SALES - p.PREV_YEAR_SALES) / NULLIF(p.PREV_YEAR_SALES, 0) * 100, 2), 0) AS PERCENT_CHANGE
        
FROM
(SELECT EXTRACT ( YEAR FROM OPEN_DATE) AS YEAR,
        NAME, SUM(AVAIL_BALANCE) AS YEAR_SALES,
        LAG (SUM(AVAIL_BALANCE),1,0) OVER (PARTITION BY NAME ORDER BY NAME) AS PREV_YEAR_SALES,
FROM PRODUCT
JOIN ACCOUNT
ON PRODUCT.PRODUCT_CD = ACCOUNT.PRODUCT_CD
WHERE EXTRACT ( YEAR FROM OPEN_DATE) BETWEEN 2000 AND 2003
GROUP BY EXTRACT ( YEAR FROM OPEN_DATE), NAME) p
ORDER BY p.YEAR, p.NAME;
/