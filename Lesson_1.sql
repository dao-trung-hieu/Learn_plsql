/* Yêu cầu: */
/* Bài 1. Sử dụng kiểu khai báo 1 cột %type để lấy ra tên của nhân viên có id = 2. (Bảng Employee ) */
SET SERVEROUTPUT ON
DECLARE
    v_emp_id employee.emp_id%Type := 2;
    v_first_name employee.first_name%Type;
BEGIN
    SELECT first_name 
    INTO v_first_name
    FROM employee e
    WHERE e.emp_id = v_emp_id;
    
    dbms_output.put_line(v_first_name);
END;
/    

/*Bài 2:  Sử dụng kiểu khai báo 1 dòng %Rowtype để lấy ra tất cả thông tin của nhân viên có id = 2. (Bảng Employee ) */
SET SERVEROUTPUT ON
DECLARE
    v_emp_id employee.emp_id%Type := 2;
    v_emp employee%Rowtype;
BEGIN
    SELECT *
    INTO v_emp
    FROM employee e
    WHERE e.emp_id = v_emp_id;
    
    dbms_output.put_line(v_emp.emp_id);
    dbms_output.put_line(v_emp.first_name);
    dbms_output.put_line(v_emp.last_name);
    dbms_output.put_line(v_emp.title);
END;
/    

/*Bài 3:  Sử dụng kiểu khai báo 1 dòng %Rowtype để lấy ra tất cả thông tin của nhân viên có id = 10000. (Bảng Employee ). 
Sử dụng Exception nếu không có dữ liệu trả về (When No_Data_Found Then) thì in ra câu lệnh : ‘No data with emp_id= id của nhân viên*/
SET SERVEROUTPUT ON
DECLARE
    v_emp_id employee.emp_id%Type := 10000;
    v_emp employee%Rowtype;
BEGIN
    SELECT *
    INTO v_emp
    FROM employee e
    WHERE e.emp_id = v_emp_id;
    
    dbms_output.put_line(v_emp.emp_id);
    dbms_output.put_line(v_emp.first_name);
    dbms_output.put_line(v_emp.last_name);
    dbms_output.put_line(v_emp.title);

EXCEPTION
    WHEN No_Data_Found THEN 
    dbms_output.put_line('Du lieu khong ton tai');
END;
/    

/*Bài 4: Khai báo 1 biến v_Cust_id = 1. Lấy ra tất cả thông tin khách hàng có ID = biến vừa khai báo*/  
SET SERVEROUTPUT ON
DECLARE
    v_cust_id customer.cust_id%Type := 1;
    v_cust customer%Rowtype;
BEGIN
    SELECT *
    INTO v_cust
    FROM customer c
    WHERE c.cust_id = v_cust_id;
    
    dbms_output.put_line(v_cust.cust_id);
    dbms_output.put_line(v_cust.address);
    dbms_output.put_line(v_cust.city);
    
EXCEPTION 
    wHEN No_Data_Found THEN
    dbms_output.put_line('Du lieu khong ton tai');
END;
/    
    
/*Bài 5:  Sử dụng kiểu khai báo Table để lấy ra tất cả thông tin:  “ID - FIRSTNAME - LASTNAME” (Bảng Employee )
Hiện thị ra màn hình bằng lệnh: dbms_output.put_line().*/
SET SERVEROUTPUT ON
DECLARE 
    Type t_temp_storage IS Table of employee%Rowtype;
    my_temp_storage t_temp_storage;
BEGIN
    SELECT * Bulk collect
    INTO my_temp_storage 
    FROM employee;
    
    for i in 1..my_temp_storage.count
        loop
        dbms_output.put_line('here I am'||my_temp_storage(i).emp_id);
        end loop;    
END;
/

/* HomeWork:*/
/* Exercises 1: 2 variable a,b(interger) are 10 and 20
calculate a+b and a-b and a*b and a/b*/
SET SERVEROUTPUT ON
DECLARE
    v_a integer := 10;
    v_b integer := 20;
    v_c integer;
BEGIN
    v_c := v_a + v_b;
    dbms_output.put_line('a+b = '||v_c);
    v_c := v_a - v_b;
    dbms_output.put_line('a-b = '||v_c);
    v_c := v_a * v_b;
    dbms_output.put_line('a*b = '||v_c);
    v_c := v_a / v_b;
    dbms_output.put_line('a/b = '||v_c);
END;
/    

/* Exercises 2: calculate circle with radius = 9.4*/
SET SERVEROUTPUT ON
DECLARE
    v_radius float := 9.4;
    v_area float;
BEGIN
    v_area := 3.14 * v_radius * v_radius;
    dbms_output.put_line('Area of circle = '||v_area);
END; 
/   

/* Exercises 3: to collect customer information including id, address from customer table and first name, last name, birth date from individual table having customer id = 4*/
SET SERVEROUTPUT ON
DECLARE
    v_cust_id customer.cust_id%Type := 4;
    v_cust customer%Rowtype;
    v_ind individual%Rowtype;
BEGIN
    SELECT *
    INTO v_cust
    FROM customer c
    WHERE c.cust_id = v_cust_id;
    
    SELECT *
    INTO v_ind
    FROM individual i
    WHERE i.cust_id = v_cust_id;
    
    dbms_output.put_line(v_cust.cust_id);
    dbms_output.put_line(v_cust.address);
    dbms_output.put_line(v_ind.first_name);
    dbms_output.put_line(v_ind.last_name);
    dbms_output.put_line(v_ind.birth_date);
END;
/





/* Excercises 4: Using %Type declaration to get the name of the customer from invidual table who have the most accounts in account table */
SET SERVEROUTPUT ON
DECLARE
    v_first_name individual.first_name%Type;
    v_account account.account_id%Type;
    v_sum_accounts v_account%Type;
BEGIN
    SELECT COUNT(ACCOUNT_ID) AS SUM_ACCOUNTS, FIRST_NAME
    INTO v_sum_accounts, v_first_name
    FROM individual i
    JOIN account a ON i.cust_id = a.cust_id
    GROUP BY FIRST_NAME
    ORDER BY SUM_ACCOUNTS DESC
    FETCH FIRST ROW ONLY;

    dbms_output.put_line('Customer with most accounts: '||v_first_name);
END;
/

/* Excercises 5: Use the appropriate variable declaration to get the minimum, maximum, and average available balance (AVAIL_BALANCE) of the account (ACCOUNT table) */ 
SET SERVEROUTPUT ON
DECLARE
    v_min_balance account.avail_balance%Type;
    v_max_balance account.avail_balance%Type;
    v_avg_balance account.avail_balance%Type;
BEGIN
    SELECT 
        MIN(AVAIL_BALANCE) AS MIN_BALANCE, 
        MAX(AVAIL_BALANCE) AS MAX_BALANCE, 
        AVG(AVAIL_BALANCE) AS AVG_BALANCE
    INTO 
        v_min_balance, 
        v_max_balance, 
        v_avg_balance
    FROM account;

    dbms_output.put_line('Minimum available balance: '||v_min_balance);
    dbms_output.put_line('Maximum available balance: '||v_max_balance);
    dbms_output.put_line('Average available balance: '||v_avg_balance);
END;
/

/* Excercises 6: Using the Table declaration type, get 2 sets of employees:
+ Employee set 1: Employees with ID > 4
+ Employee set 2: Employees with ID < 2
Union 2 set of employees together
Request:
1. Print the total number of employees on the screen
2. Print out the first employee's stats
3. Print out the last employee stats
4. Print out ID + Employee Name in turn
*/ 
SET SERVEROUTPUT ON
DECLARE
    Type t_emp_set IS Table of employee%Rowtype;
    emp_set1 t_emp_set;
    emp_set2 t_emp_set;
BEGIN
    SELECT * Bulk collect
    INTO emp_set1
    FROM employee
    WHERE emp_id > 4;
    
    SELECT * Bulk collect
    INTO emp_set2
    FROM employee
    WHERE emp_id < 2;
    
    -- union 2 set of employees together
    emp_set1 := emp_set2 MULTISET UNION emp_set1;

    -- print the total number of employees on the screen
    dbms_output.put_line('Total number of employees: '||emp_set1.count);

    -- print out the first employee's stats
    dbms_output.put_line('First employee: '||emp_set1(1).emp_id||' '||emp_set1(1).first_name||' '||emp_set1(1).last_name);

    -- print out the last employee stats
    dbms_output.put_line('Last employee: '||emp_set1(emp_set1.count).emp_id||' '||emp_set1(emp_set1.count).first_name||' '||emp_set1(emp_set1.count).last_name);

    -- print out ID + Employee Name in turn
    FOR i IN 1..emp_set1.count LOOP
        dbms_output.put_line(emp_set1(i).emp_id||' '||emp_set1(i).first_name||' '||emp_set1(i).last_name);
    END LOOP;
END;
/