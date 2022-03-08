---- SEQUENCE --------
/*Exercises 1:
+ Generate a Sequence of my_seq, starting at 1, incrementing 1, min value 1, max value 10, using Cycle option
+ Get the next 10 values of the Sequence
+ Get the current value of Sequence */

CREATE SEQUENCE hieu_sequence
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 10
CACHE 10;

/*Exercises 2:
+ Create a table according to the following form:
CREATE TABLE My_Table(
     id NUMBER PRIMARY KEY,
     title VARCHAR2(255) NOT NULL
);
+ INSERT 2 new records into table My_Table with ID: self-increment using Sequence lesson 1, Title: Optional
+ Execute Select query to check*/

CREATE TABLE HIEU_TABLE(
     ID NUMBER PRIMARY KEY,
     TITLE VARCHAR2(255) NOT NULL
);

INSERT INTO HIEU_TABLE(ID,TITLE)
VALUES(HIEU_SEQUENCE.NEXTVAL,'Hieu');

INSERT INTO HIEU_TABLE(ID,TITLE)
VALUES(HIEU_SEQUENCE.NEXTVAL,'Hieu');

------ TRANSACTION -------
/* Excerises 1:
+ Add 1 new record to the table 'HOCVIEN_CUSTOMER' then use COMMIT
+ Add 1 new record to the table 'HOCVIEN CUSTOMER' then use ROLLBACK
Select data and make comments */

INSERT INTO HIEU_CUSTOMER (CUST_ID, ADDREES, CITY, CUST_TYPE_ID, FED_ID, POSTAL_CODE, STATE)
VALUES (1, '123 Hanoi', 'Hanoi', D, 095-55-1234, 022475, 'HN');
COMMIT;

INSERT INTO HIEU_CUSTOMER (CUST_ID, ADDREES, CITY, CUST_TYPE_ID, FED_ID, POSTAL_CODE, STATE)
VALUES (1, '123 Hanoi', 'Hanoi', D, 095-55-1234, 022475, 'HN');
ROLLBACK;

/*Exercises 2:
+ Add 1 new write to the table ‘HOCVIEN_CUSTOMER’ after that use SAVEPOINT + Name_saveponint
+ Xóa bản ghi trước đó (bản ghi có ID sau bản ghi vừa thêm)
+ Sử dụng lệnh ROLLBACK TO Name_saveponint
+ Tiếp tục sử dụng COMMIT*/

-- Insert rows in a Table

INSERT INTO HIEU_CUSTOMER (CUST_ID, ADDREES, CITY, CUST_TYPE_ID, FED_ID, POSTAL_CODE, STATE)
VALUES (1, '123 Hanoi', 'Hanoi', D, 095-55-1234, 022475, 'HN');
SAVEPOINT HIEU_SAVEPOINT;

DELETE FROM HIEU_CUSTOMER WHERE CUST_ID = 1;
ROLLBACK TO HIEU_SAVEPOINT;
COMMIT;

