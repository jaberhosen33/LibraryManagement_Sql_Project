use LibraryManagementDB;
go

-- Insert records  Authors table
INSERT INTO Authors (AuthorID,FirstName, LastName)
VALUES 
(1,'Robert', 'Martin'),     
(2,'C.J.', 'Date'),         
(3,'Andrew', 'Tanenbaum'),  
(4,'Charles', 'Petzold'),   
(5,'Glenford', 'Myers'),    
(6,'Martin', 'Fowler'),     
(7,'Thomas', 'Connolly'),   
(8,'William', 'Stallings'), 
(9,'Scott', 'Mueller'),     
(10,'Paul', 'Clements');     
GO
-- Insert records  Categories table
INSERT INTO Categories (CategoryName)
VALUES 
('Programming'),
('Database'),
('Operating System'),
('Hardware'),
('Testing');
GO
-- Insert records  Books table
INSERT INTO Books (Title, AuthorID, CategoryID, PublishedYear, AvailableCopies)
VALUES 
('Clean Code', 1, 1, 2008, 5),                       
('Database System Concepts', 2, 2, 2010, 3),         
('Modern Operating Systems', 3, 3, 2014, 4),         
('Code: The Hidden Language', 4, 4, 2000, 2),        
('The Art of Software Testing', 5, 5, 2004, 3),      
('Refactoring', 6, 1, 1999, 6),                      
('Database Systems: A Practical Approach', 7, 2, 2011, 5),
('Operating System Concepts', 8, 3, 2008, 4),        
('Upgrading and Repairing PCs', 9, 4, 2013, 7),     
('Software Architecture in Practice', 10, 5, 2012, 3); 
GO

-- Insert records  Members table

INSERT INTO Members (FirstName, LastName, Email, PhoneNumber, Address, MembershipDate)
VALUES 
('Jaber', 'Hosen', 'Jaber@gmal.com', '+8801234567890', '123 Gulshan Avenue, Dhaka', '2024-01-15'),
('Asif', 'Mahmud', 'Asif@gmal.com', '+8802345678901', '456 Banani Road, Dhaka', '2023-02-20'),
('Mejbah', 'Uddin', 'Mejbah@gmal.com', '+8803456789012', '789 Dhanmondi 32, Dhaka', '2024-03-05'),
('Tanvir', 'Hasan', 'Tanvir@gmal.com', '+8804567890123', '101 Uttara Sector 4, Dhaka', '2024-04-10'),
('Arafat', 'Islam', 'Arafat@gmal.com', '+8805678901234', '202 Mirpur Road, Dhaka', '2024-05-25');
GO

INSERT INTO Loans (BookID, MemberID, LoanDate, CommitedReturnDate)
VALUES 
(1, 1, '2024-08-01', '2024-08-15'), 
(2, 2, '2024-08-02', '2024-08-10'),
(3, 3, '2024-08-03', '2024-08-15'),
(4, 4, '2024-08-04', '2024-08-15'),
(5, 5, '2024-08-05', '2024-08-15'),
(6, 1, '2024-08-06', '2024-08-16'),  
(7, 2, '2024-08-07', '2024-08-17'),  
(8, 3, '2024-08-08', '2024-08-18'),  
(9, 4, '2024-08-09', '2024-08-19'),  
(10, 5, '2024-08-10', '2024-08-17'); 
GO

INSERT INTO Returns (LoanID, ReturnDate, Condition)
VALUES 
(2, '2024-08-10', 'Good'),   
(5, '2024-08-15', 'Poor');  
GO
-----show all table data 
select * from Authors;
go
select * from  Categories;
GO
select * from Books;
GO
select * from Members;
GO
select * from Loans;
GO
select * from [Returns];
GO
-----1. retrieve the names of all books that belong to the 'Programming' category and were published after 2005.

SELECT * 
FROM Books 
JOIN Categories ON Books.CategoryID = Categories.CategoryID
WHERE Categories.CategoryName = 'Programming' 
AND PublishedYear > 2005;

go
---2 retrieve the total number of available copies for each category in the library.

SELECT Categories.CategoryName, SUM(Books.AvailableCopies) AS TotalAvailableCopies
FROM Books
JOIN Categories ON Books.CategoryID = Categories.CategoryID
GROUP BY Categories.CategoryName;

 -----*SubQuery* find members who have loaned a book  BookID=1

SELECT FirstName +' '+ LastName as fullName
FROM Members
WHERE MemberID IN (
    SELECT MemberID
    FROM Loans
    WHERE BookID = 1
);
go
-----*SubQuery*  find the category with  highest number of books:

SELECT CategoryName
FROM Categories
WHERE CategoryID = (
    SELECT TOP 1 CategoryID
    FROM Books
    GROUP BY CategoryID
    ORDER BY COUNT(*) DESC
);
go
---CUBE operator.	
SELECT AuthorID, CategoryID, SUM(AvailableCopies) AS TotalCopies
FROM Books
GROUP BY CUBE(AuthorID, CategoryID);
go

 -----ROLLUP operator
SELECT AuthorID, CategoryID, SUM(AvailableCopies) AS TotalCopies
FROM Books
GROUP BY ROLLUP(AuthorID, CategoryID);
go

----GROUPING SETS operator.
SELECT AuthorID, CategoryID, SUM(AvailableCopies) AS TotalCopies
FROM Books
GROUP BY GROUPING SETS (
    (AuthorID),
    (CategoryID),
    (AuthorID, CategoryID),
    ()
);
go
-----OVER clause.
SELECT Title, PublishedYear, 
       RANK() OVER (ORDER BY PublishedYear DESC) AS RankByYear
FROM Books;
go

----ANY keyword.
SELECT BookID, Title
FROM Books
WHERE AvailableCopies > ANY (
    SELECT AvailableCopies 
    FROM Books 
    WHERE CategoryID = 1
);
go
-----ALL keyword.
SELECT BookID, Title
FROM Books
WHERE AvailableCopies > ALL (
    SELECT AvailableCopies 
    FROM Books 
    WHERE CategoryID = 1
);
go
---- SOME keyword.
SELECT BookID, Title
FROM Books
WHERE AvailableCopies > SOME (
    SELECT AvailableCopies 
    FROM Books 
    WHERE CategoryID = 1
);
go
---- correlated subquery.
SELECT MemberID, FirstName, LastName
FROM Members m
WHERE EXISTS (
    SELECT 1 
    FROM Loans l
    WHERE l.MemberID = m.MemberID
    AND l.LoanDate > '2024-01-01'
);
go
----EXISTS operator.
SELECT Title
FROM Books b
WHERE EXISTS (
    SELECT 1 
    FROM Loans
    WHERE Loans.BookID = b.BookID
);
go
----CTE 
WITH BookLoans AS (
    SELECT BookID, COUNT(*) AS LoanCount
    FROM Loans
    GROUP BY BookID
)
SELECT b.Title, bl.LoanCount
FROM Books b
JOIN BookLoans bl ON b.BookID = bl.BookID;
go

----CASE FUNCTION

SELECT Title, 
       CASE 
           WHEN PublishedYear > 2010 THEN 'Modern'
           WHEN PublishedYear BETWEEN 2000 AND 2010 THEN 'Contemporary'
           ELSE 'Old'
       END AS BookAgeCategory
FROM Books;
go

----IIF FUNCTION
SELECT Title, 
       IIF(AvailableCopies > 5, 'Sufficient Copies', 'Low Copies') AS CopyStatus
FROM Books;
go

-----CHOOSE FUNCTION
SELECT Title, 
       CHOOSE(CategoryID, 'Programming', 'Database', 'Operating System', 'Hardware', 'Testing') AS CategoryName
FROM Books;
go

-----COALESCE FUNCTION
SELECT Title, 
       COALESCE(AvailableCopies, 0) AS AvailableCopies
FROM Books;
go

---- ISNULL FUNCTION
SELECT Title, 
       ISNULL(AvailableCopies, 0) AS AvailableCopies
FROM Books;
go

----GROUPING function
SELECT 
    AuthorID, 
    SUM(AvailableCopies) AS TotalCopies, 
    GROUPING(AuthorID) AS AuthorGrouped
    
FROM Books
GROUP BY ROLLUP(AuthorID);
GO

-- view  with encryption

SELECT * 
FROM ShowBooks;
GO

--view with Schemabinding   
SELECT * 
FROM ShowBooksName;
GO


-- view with Schemabinding  ,encryption 
SELECT * 
FROM ShowBooksCopys;
GO


-- Using  the SCALER FUNCTION
SELECT dbo.TotalAvailableCopies() AS TotalCopies;
GO

-- Using the table valued function 
SELECT * FROM dbo.BooksWithAuthors();
go


--  using the Stored Procedure to select

DECLARE @_Status VARCHAR(20);
EXEC SP_CRUD_Authors 
    @AuthorID = 1, 
    @FirstName = '', 
    @LastName = '',
    @StatementType = 'SELECT',
    @Status = @_Status OUTPUT;
SELECT @_Status AS output_parameter;
go
--  using the Stored Procedure to Update
DECLARE @_Status VARCHAR(20);
EXEC SP_CRUD_Authors 
    @AuthorID = 1,
    @FirstName = 'John', 
    @LastName = 'Smith',
    @StatementType = 'UPDATE',
    @Status = @_Status OUTPUT;

SELECT @_Status AS output_parameter;
go

--  using the procedure to Delete
DECLARE @_Status VARCHAR(20);
EXEC SP_CRUD_Authors 
    @AuthorID = 11,
    @FirstName = '', 
    @LastName = '',
    @StatementType = 'DELETE',
    @Status = @_Status OUTPUT;
SELECT @_Status AS output_parameter;
go
--  using the procedure Insert

DECLARE @_Status VARCHAR(20);
EXEC SP_CRUD_Authors 
    @AuthorID = 11, 
    @FirstName = 'John', 
    @LastName = 'Charls',
    @StatementType = 'INSERT',
    @Status = @_Status OUTPUT;
SELECT @_Status AS output_parameter;

go

-- Insert a test record for trigger  
INSERT INTO Returns (LoanID, ReturnDate, Condition)
VALUES (5, '2024-08-15', 'Poor'),(6, '2024-08-15', 'Good');
go

-- trigger output   LoanStatus table.
SELECT * FROM LoanStatus;
go

-- Insert a test record for raise error trigger  
DELETE  Categories WHERE CategoryID = 2;
go
-- View  categories
SELECT * FROM Categories;
go
-- View log entries
SELECT * FROM log_info;
go
