-- SQL Project - Library Management System
SELECT
    *
FROM
    books;

SELECT
    *
FROM
    branch;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    members;

SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    return_status;

-- Project Task
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO
    books (
        isbn,
        book_title,
        category,
        rental_price,
        status,
        author,
        publisher
    )
VALUES
    (
        '978-1-60129-456-2',
        'To Kill a Mockingbird',
        'Classic',
        6.00,
        'yes',
        'Harper Lee',
        'J.B. Lippincott & Co.'
    );

-- Task 2: Update an Existing Member's Address
UPDATE members
SET
    member_address = '125 Main St'
WHERE
    member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE
    issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT
    issued_book_name
FROM
    issued_status
WHERE
    issued_emp_id = 'E101';

-- Task 5: List Members(Employees) Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT
    issued_emp_id
FROM
    issued_status
GROUP BY
    issued_emp_id
HAVING
    COUNT(*) > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
-- Approach #1
CREATE TABLE book_issued_cnt_simple AS
SELECT
    issued_book_isbn AS isbn,
    issued_book_name AS book_title,
    COUNT(*) AS book_issued_count
FROM
    issued_status
GROUP BY
    1,
    2
ORDER BY
    2;

-- Approach #2: Using Join
CREATE TABLE book_issued_cnt AS
SELECT
    b.isbn,
    b.book_title,
    COUNT(*) AS book_issued_count
FROM
    books b
    JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY
    1,
    2
ORDER BY
    2;

-- Task 7. Retrieve All Books in a Specific Category:
SELECT
    *
FROM
    books
WHERE
    category = 'Classic';

-- Task 8: Find Total Rental Income by Category:
SELECT
    b.category,
    SUM(b.rental_price) AS total_rental_income,
    COUNT(*)
FROM
    books b
    JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY
    1;

-- List Members Who Registered in the Last 180 Days:
SELECT
    *
FROM
    members
WHERE
    reg_date >= CURRENT_DATE - INTERVAL '180 days'
    -- task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    branch;

SELECT
    e1.*,
    b.manager_id,
    e2.emp_name AS manager,
    b.branch_address,
    b.contact_no
FROM
    employees e1
    JOIN branch b ON e1.branch_id = b.branch_id
    JOIN employees e2 ON b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
SELECT
    *
FROM
    books
WHERE
    rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT
    *
FROM
    return_status;

SELECT
    *
FROM
    issued_status;

SELECT DISTINCT
    i.issued_book_name
FROM
    issued_status i
    LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE
    r.return_id IS NULL;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT
    *
FROM
    return_status;

-- issued_status join members join books join return_status
-- filter book which is returned
SELECT
    CURRENT_DATE;

SELECT
    i.issued_member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    CURRENT_DATE - i.issued_date AS over_dues_date
FROM
    issued_status i
    JOIN members m ON i.issued_member_id = m.member_id
    JOIN books b ON i.issued_book_isbn = b.isbn
    LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE
    r.return_date IS NULL
    AND CURRENT_DATE - i.issued_date > 30
ORDER BY
    1;

-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
SELECT
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-0-451-52994-2';

SELECT
    *
FROM
    books
WHERE
    isbn = '978-0-451-52994-2';

UPDATE books
SET
    status = 'no'
WHERE
    isbn = '978-0-451-52994-2';

SELECT
    *
FROM
    return_status
WHERE
    issued_id = 'IS130';

-- Approach#1: Manual updating when book is returned:
INSERT INTO
    return_status (return_id, issued_id, return_date, book_quality)
VALUES
    ('R125', 'IS130', CURRENT_DATE, 'Good');

SELECT
    *
FROM
    return_status
WHERE
    issued_id = 'IS130';

UPDATE books
SET
    status = 'yes'
WHERE
    isbn = '978-0-451-52994-2';

-- Approach#2: Stored Procedures
-- Testing the changes
SELECT
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-0-451-52994-2';

SELECT
    *
FROM
    books
WHERE
    isbn = '978-0-451-52994-2';

SELECT
    *
FROM
    return_status
WHERE
    issued_id = 'IS130';

-- Stored PROCEDURE
CREATE
OR REPLACE procedure add_return_records (
    p_return_id VARCHAR(10),
    p_issue_id VARCHAR(10),
    p_book_quality VARCHAR(10)
) language plpgsql AS $$

-- Declare variables
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- Logic and code
    -- Insert into return_status
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issue_id, CURRENT_DATE, p_book_quality);

    -- assign variables
    SELECT
        issued_book_isbn,
        issued_book_name
        INTO 
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issue_id;
    
    -- Update status in books
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Print/Display message
    RAISE NOTICE '% has been returned on %', v_book_name, CURRENT_DATE;
    
END;
$$
-- Calling the stored procedure
CALL add_return_records ('RS145', 'IS130', 'Damaged');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
-- issued_status join empolyees join branch join books join return_status
SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    branch;

SELECT
    *
FROM
    return_status;

SELECT
    *
FROM
    books;

CREATE TABLE branch_performance_report AS
SELECT
    b.branch_id,
    b.manager_id,
    COUNT(i.issued_id) AS total_books_issued,
    COUNT(r.return_id) AS total_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM
    issued_status i
    JOIN employees e ON i.issued_emp_id = e.emp_id
    JOIN branch b ON e.branch_id = b.branch_id
    LEFT JOIN return_status r ON i.issued_id = r.issued_id
    JOIN books bk ON i.issued_book_isbn = bk.isbn
GROUP BY
    1,
    2;

SELECT
    *
FROM
    branch_performance_report;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
SELECT
    CURRENT_DATE - INTERVAL '2 months';

SELECT
    *
FROM
    issued_status
WHERE
    issued_date >= (CURRENT_DATE - INTERVAL '2 months');

DROP TABLE IF EXISTS active_members;

CREATE TABLE active_members AS
SELECT
    *
FROM
    members
WHERE
    member_id IN (
        SELECT DISTINCT
            issued_member_id
        FROM
            issued_status
        WHERE
            issued_date >= (CURRENT_DATE - INTERVAL '2 months')
    );

SELECT
    *
FROM
    active_members;

-- 
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    issued_status;

SELECT
    e.emp_name,
    b.*,
    COUNT(i.issued_id) AS books_issued
FROM
    issued_status i
    JOIN employees e ON e.emp_id = i.issued_emp_id
    JOIN branch b ON b.branch_id = e.branch_id
GROUP BY
    1,
    2
ORDER BY
    3 DESC
LIMIT
    3;

/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
-- books join issued_status
SELECT
    *
FROM
    books;

SELECT
    *
FROM
    issued_status;

CREATE
OR REPLACE PROCEDURE issue_book (
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(10),
    p_issued_book_isbn VARCHAR(60),
    p_issued_emp_id VARCHAR(10)
) LANGUAGE plpgsql AS $$

DECLARE
v_status varchar(15);
v_book_name varchar(60);

BEGIN
-- main logic
-- get status and book name from books table
SELECT status, book_title
INTO v_status, v_book_name
FROM books
WHERE isbn = p_issued_book_isbn;

-- check if book is available - book status = 'yes'
IF v_status = 'yes' THEN
INSERT INTO
    issued_status (
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id
    )
VALUES
    (
        p_issued_id,
        p_issued_member_id,
        v_book_name,
        CURRENT_DATE,
        p_issued_book_isbn,
        p_issued_emp_id
    );

-- Update the books status after issuance
UPDATE books
SET
    status = 'no'
WHERE
    isbn = p_issued_book_isbn;

RAISE NOTICE '% has been issued',
v_book_name;

ELSE RAISE NOTICE '% is not available',
v_book_name;

END IF;

END;
$$

CALL
issue_book('IS199', 'C108', '978-0-553-29698-2', 'E104');