# LibraryManagement_Sql_Project
The Library Management System is designed to assist libraries manage their operations, such as book management, member records, loans, and returns. It makes use of a structured database named LibraryManagementDB


## Project Description
The Library Management System is designed to assist libraries manage their operations, such as book management, member records, loans, and returns. It makes use of a structured database named LibraryManagementDB, which was created using SQL Server. The database structure includes tables for authors, categories, books, members, loans, and returns. Views, functions, stored procedures, and triggers are additional characteristics that allow for enhanced functionality.

## Features

### Database
- **Creation**: Fixed-size files with growth limits for efficient storage.

### Tables
- Tables for:
  - Authors
  - Categories
  - Books
  - Members
  - Loans
  - Returns
- Relational integrity maintained with primary and foreign keys.

### Views
- Encrypted and schema-bound views for encapsulated and secure data access.

### Functions
- **Scalar Function**: Calculates the total available copies of books.
- **Table-Valued Function**: Fetches book details along with author information.

### Stored Procedures
- **CRUD Operations**: For managing authors with output status indicators.

### Triggers
- **After-Insert Trigger**: Computes fines for late or damaged book returns.
- **Instead-Of-Delete Trigger**: Implements error-raising logic for specific categories.

### Indexes
- Non-clustered indexes on author names for faster search.

### Advanced SQL Queries
- **Subqueries**: Fetch data such as books in the "Programming" category or members who borrowed a specific book.
- **Grouping Operators**: Utilizes `CUBE`, `ROLLUP`, and `GROUPING SETS` for data summarization.
- **Over Clause**: Ranks books by publication year.
- **Conditional Functions**: Uses `CASE`, `IIF`, and `CHOOSE` for categorized data.

### Data Integrity and Testing
- Includes test cases and example records to demonstrate the functionality of triggers, functions, and procedures.


## Summary
This project highlights complete database design, complex query techniques, and SQL-based business logic implementation. It maintains data integrity and facilitates efficient library operations.

---

### Usage
1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Set up the database using the provided SQL scripts.
3. Test the features using the sample test cases.

### Contribution
Feel free to fork this repository and submit pull requests for improvements or new features.

---


