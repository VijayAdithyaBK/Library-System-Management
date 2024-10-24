Here is a draft README based on your SQL project, integrating the code from your library management system:

---

# Library Management System - SQL Project

## Overview
This project is a simple Library Management System using SQL to manage books, branches, employees, members, and issued/return statuses. It demonstrates fundamental SQL operations such as creating, reading, updating, and deleting (CRUD) records, as well as more advanced queries like joins, grouping, and stored procedures.

### Prerequisites
- PostgreSQL or any SQL-based database installed
- A database environment to run SQL queries

### Tables Used
- **books**: Stores information about each book in the library.
- **branch**: Stores details of different library branches.
- **employees**: Contains records of employees working at different branches.
- **members**: Lists all members of the library.
- **issued_status**: Tracks issued books, including who issued the book and when.
- **return_status**: Manages details about returned books.

## SQL Tasks

### Task 1: Create a New Book Record
```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

### Task 2: Update an Existing Member's Address
```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

### Task 3: Delete a Record from the Issued Status Table
```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

### Task 4: Retrieve All Books Issued by a Specific Employee
```sql
SELECT issued_book_name
FROM issued_status
WHERE issued_emp_id = 'E101';
```

### Task 5: List Members Who Have Issued More Than One Book
```sql
SELECT issued_emp_id
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
```

### Task 6: Create Summary Tables for Books and Count of Books Issued
```sql
CREATE TABLE book_issued_cnt_simple AS
SELECT issued_book_isbn AS isbn, issued_book_name AS book_title, COUNT(*) AS book_issued_count
FROM issued_status
GROUP BY 1, 2
ORDER BY 2;
```

### Task 7: Retrieve All Books in a Specific Category
```sql
SELECT * FROM books WHERE category = 'Classic';
```

### Task 8: Find Total Rental Income by Category
```sql
SELECT b.category, SUM(b.rental_price) AS total_rental_income, COUNT(*)
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY 1;
```

### Task 9: List Members Registered in the Last 180 Days
```sql
SELECT * FROM members WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

### Task 10: List Employees with Branch Manager's Name and Branch Details
```sql
SELECT e1.*, b.manager_id, e2.emp_name AS manager, b.branch_address, b.contact_no
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id;
```

### Task 11: Create a Table of Books with Rental Price Above a Certain Threshold
```sql
SELECT * FROM books WHERE rental_price > 7;
```

### Task 12: Retrieve the List of Books Not Yet Returned
```sql
SELECT DISTINCT i.issued_book_name
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
```

### Task 13: Identify Members with Overdue Books
```sql
SELECT i.issued_member_id, m.member_name, b.book_title, i.issued_date, CURRENT_DATE - i.issued_date AS over_dues_date
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN books b ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_date IS NULL AND CURRENT_DATE - i.issued_date > 30
ORDER BY 1;
```

### Task 14: Update Book Status on Return
```sql
UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';
```

### Task 15: Branch Performance Report
```sql
CREATE TABLE branch_performance_report AS
SELECT b.branch_id, b.manager_id, COUNT(i.issued_id) AS total_books_issued, COUNT(r.return_id) AS total_books_returned, SUM(bk.rental_price) AS total_revenue
FROM issued_status i
JOIN employees e ON i.issued_emp_id = e.emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
JOIN books bk ON i.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
```

### Task 16: Create a Table of Active Members
```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= (CURRENT_DATE - INTERVAL '2 months')
);
```

### Task 17: Find Employees with the Most Book Issues Processed
```sql
SELECT e.emp_name, b.*, COUNT(i.issued_id) AS books_issued
FROM issued_status i
JOIN employees e ON e.emp_id = i.issued_emp_id
JOIN branch b ON b.branch_id = e.branch_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 3;
```

### Task 18: Stored Procedure for Issuing Books
```sql
CREATE OR REPLACE PROCEDURE issue_book (
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(10),
    p_issued_book_isbn VARCHAR(60),
    p_issued_emp_id VARCHAR(10)
) LANGUAGE plpgsql AS $$

DECLARE
    v_status varchar(15);
    v_book_name varchar(60);

BEGIN
    -- Retrieve book status and name
    SELECT status, book_title INTO v_status, v_book_name
    FROM books WHERE isbn = p_issued_book_isbn;

    -- Check availability
    IF v_status = 'yes' THEN
        INSERT INTO issued_status (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, v_book_name, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
        -- Update book status
        UPDATE books SET status = 'no' WHERE isbn = p_issued_book_isbn;
        
        RAISE NOTICE '% has been issued', v_book_name;
    ELSE
        RAISE NOTICE '% is not available', v_book_name;
    END IF;
END;
$$;
```

---

This README outlines all the tasks you performed in the Library Management System using SQL, including essential CRUD operations, stored procedures, and reporting.
