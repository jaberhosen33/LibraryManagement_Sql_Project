
----Project Name :Library Management


-- Create LibraryManagementDB database 

CREATE DATABASE LibraryManagementDB
ON PRIMARY 
(
    NAME = 'LibraryManagementDB_Data',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\LibraryManagementDB_Data.mdf',
    SIZE = 25MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5%
)
LOG ON 
(
    NAME = 'LibraryManagementDB_Log',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\LibraryManagementDB_Log.ldf',
    SIZE = 2MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 1MB
);
go

use LibraryManagementDB;
go

-- Create Authors Table
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50)
);
GO

-- Create Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50)
);
GO

-- Create Books Table
CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100),
    AuthorID INT,
    CategoryID INT,
    PublishedYear INT,
    AvailableCopies INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- Create Members Table
CREATE TABLE Members (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(15),
    Address NVARCHAR(200),
    MembershipDate DATE
);
GO

-- Create Loans Table
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    BookID INT,
    MemberID INT,
    LoanDate DATE,
    CommitedReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);
GO
-- Create Returns Table
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT,
    ReturnDate DATE,
    Condition NVARCHAR(50),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);
GO

--Create  View with encryption 

CREATE VIEW ShowBooks
WITH ENCRYPTION 
AS 
SELECT * 
FROM Books;
GO

--Create View with Schemabinding  
CREATE VIEW ShowBooksName
WITH SCHEMABINDING 
AS 
SELECT Title 
FROM dbo.Books;
GO

--Create View with Schemabinding  ,encryption 
CREATE VIEW ShowBooksCopys
WITH SCHEMABINDING, ENCRYPTION
AS 
SELECT AvailableCopies 
FROM dbo.Books;
GO

---------SCALER FUNCTION
CREATE FUNCTION TotalAvailableCopies()
RETURNS INT
AS
BEGIN
    DECLARE @TotalCopies INT;
    
    SELECT @TotalCopies = SUM(AvailableCopies)
    FROM Books;
    
    RETURN @TotalCopies;
END;
GO

------ Create Table Valued Function
CREATE FUNCTION BooksWithAuthors()
RETURNS TABLE
AS
RETURN
(
SELECT 
        b.BookID,
        b.Title,
        b.AvailableCopies,
		a.FirstName  AS AuthornMAE

 FROM Books b
 JOIN Authors a ON b.AuthorID = a.AuthorID
);
go

-- Create Stored Procedure to Update,delete,select,insert Table

CREATE PROCEDURE SP_CRUD_Authors
(
    @AuthorID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50), 
    @StatementType  VARCHAR(20), 
    @Status VARCHAR(20) OUTPUT 
)
AS
BEGIN
    IF @StatementType = 'SELECT'
    BEGIN
        SET @Status = 'selected';
        IF @AuthorID = 0
        BEGIN
            SELECT * FROM Authors;
        END
        ELSE
        BEGIN
            SELECT * FROM Authors WHERE AuthorID = @AuthorID;
        END
        RETURN;
    END

    
    IF @StatementType = 'INSERT'
    BEGIN
        IF @AuthorID IS NULL
        BEGIN
            SET @Status = 'AuthorID cannot be NULL for INSERT';
        END
        ELSE
        BEGIN
            INSERT INTO Authors (AuthorID, FirstName, LastName)
            VALUES (@AuthorID, @FirstName, @LastName);
            SET @Status = 'inserted';
        END
    END

    IF @StatementType = 'UPDATE'
    BEGIN
        UPDATE Authors
        SET FirstName = @FirstName, LastName = @LastName
        WHERE AuthorID = @AuthorID;
        SET @Status = 'updated';
    END

    IF @StatementType = 'DELETE'
    BEGIN
        DELETE FROM Authors
        WHERE AuthorID = @AuthorID;
        SET @Status = 'deleted';
    END
END;
GO

-- Create LoanStatus Table
CREATE TABLE LoanStatus (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT,
    ReturnID INT,
    FineAmount DECIMAL(10, 2),
    Status NVARCHAR(50),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID),
    FOREIGN KEY (ReturnID) REFERENCES Returns(ReturnID)
);
GO
-- Create AFTER INSERT Trigger on Returns Table
CREATE TRIGGER trg_AfterInsert_Returns
ON Returns
AFTER INSERT
AS
BEGIN
    DECLARE @ReturnID INT;
    DECLARE @LoanID INT;
    DECLARE @ReturnDate DATE;
    DECLARE @Condition NVARCHAR(50);
    DECLARE @CommitedReturnDate DATE;
    DECLARE @FineAmount DECIMAL(10, 2);
    DECLARE @Status NVARCHAR(50);
    SELECT 
        @ReturnID = i.ReturnID,
        @LoanID = i.LoanID,
        @ReturnDate = i.ReturnDate,
        @Condition = i.Condition
    FROM inserted i;
    SELECT @CommitedReturnDate = CommitedReturnDate FROM Loans WHERE LoanID = @LoanID;
    IF @Condition = 'Poor' OR @ReturnDate > @CommitedReturnDate
    BEGIN
        SET @FineAmount = 200.00;
        SET @Status = 'Fine Applied';
    END
    ELSE
    BEGIN
        SET @FineAmount = 0.00;
        SET @Status = 'No Fine';
    END
    INSERT INTO LoanStatus (LoanID, ReturnID, FineAmount, Status)
    VALUES (@LoanID, @ReturnID, @FineAmount, @Status);
END;
GO

----create table for raise error trigger
CREATE TABLE log_info(
    logId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT,
    status VARCHAR(100)
);
GO

---create trigger with raise error

CREATE TRIGGER TriggerWithRaiserror
ON Categories
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @CategoryID INT;
    SELECT @CategoryID = deleted.CategoryID FROM deleted;

    IF @CategoryID = 2
    BEGIN
        RAISERROR ('Cannot delete CategoryID 2', 16, 1);
        ROLLBACK TRANSACTION;
        INSERT INTO log_info (CategoryID, status) 
        VALUES (@CategoryID, 'invalid');
    END
    ELSE
    BEGIN
        DELETE FROM Categories WHERE CategoryID = @CategoryID;
        INSERT INTO log_info (CategoryID, status) 
        VALUES (@CategoryID, 'deleted');
    END
END;
GO

-- Create a non-clustered index 

CREATE NONCLUSTERED INDEX Authors_Name
ON Authors (FirstName, LastName);
GO


