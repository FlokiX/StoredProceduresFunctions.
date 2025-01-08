USE dz;
GO
CREATE TABLE Books
(
    BookID INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(255),
    Author NVARCHAR(255),
    Publisher NVARCHAR(255),
    Topic NVARCHAR(255),
    PublishDate DATE,
    Pages INT,
    Price MONEY,
    PrintRun INT,
    Copies INT
);
GO

CREATE TABLE Library
(
    RecordID INT PRIMARY KEY IDENTITY,
    StudentID INT,
    BookID INT,
    BorrowerType NVARCHAR(50), -- 'Student', 'Teacher', 'Librarian'
    BorrowDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);
GO

CREATE TABLE Students
(
    StudentID INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    DateOfBirth DATE,
    Email NVARCHAR(255),
    Phone NVARCHAR(50)
);
GO

CREATE TABLE Librarians
(
    LibrarianID INT PRIMARY KEY IDENTITY,
    LibrarianName NVARCHAR(255),
    Email NVARCHAR(255),
    Phone NVARCHAR(50)
);
GO

INSERT INTO Books (Title, Author, Publisher, Topic, PublishDate, Pages, Price, PrintRun, Copies)
VALUES
    ('Introduction to Programming', 'John Doe', 'TechBooks', 'Programming', '2020-01-01', 300, 19.99, 10000, 500),
    ('Advanced Database Systems', 'Jane Smith', 'DataPub', 'Databases', '2021-05-15', 350, 29.99, 8000, 1000),
    ('Multimedia in Web Development', 'Alan Brown', 'WebBooks', 'Web Development', '2019-09-23', 250, 15.99, 12000, 2000);
GO

INSERT INTO Library (StudentID, BookID, BorrowerType, BorrowDate, ReturnDate)
VALUES
    (1, 1, 'Student', '2024-05-10', '2024-05-20'),
    (2, 2, 'Teacher', '2024-06-01', '2024-06-15'),
    (3, 3, 'Student', '2024-07-01', '2024-07-10');
GO

INSERT INTO Students (FirstName, LastName, DateOfBirth, Email, Phone)
VALUES
    ('Mikhail', 'Klimchenko', '2006-09-12', 'mikhail@example.com', '123-456-789'),
    ('Anna', 'Petrova', '2005-04-23', 'anna@example.com', '987-654-321');
GO

INSERT INTO Librarians (LibrarianName, Email, Phone)
VALUES
    ('Elena Ivanova', 'elena.ivanova@example.com', '555-111-222'),
    ('Sergey Vasiliev', 'sergey.vasiliev@example.com', '555-333-444');
GO

CREATE FUNCTION GetBooksWithMinPagesByPublisher
(
    @Publisher NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Books
    WHERE Publisher = @Publisher
    ORDER BY Pages ASC
    OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
);
GO

CREATE FUNCTION GetPublishersWithAvgPagesGreaterThan
(
    @AvgPages INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT Publisher
    FROM Books
    GROUP BY Publisher
    HAVING AVG(Pages) > @AvgPages
);
GO

CREATE FUNCTION GetTotalPagesByPublisher
(
    @Publisher NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalPages INT;
    
    SELECT @TotalPages = SUM(Pages)
    FROM Books
    WHERE Publisher = @Publisher;
    
    RETURN @TotalPages;
END;
GO

CREATE FUNCTION GetStudentsByDateRange
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT FirstName, LastName
    FROM Library
    WHERE BorrowerType = 'Student'
    AND BorrowDate BETWEEN @StartDate AND @EndDate
);
GO

CREATE FUNCTION GetStudentsWithBookByAuthor
(
    @Author NVARCHAR(100),
    @BookTitle NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT FirstName, LastName
    FROM Library
    WHERE BorrowerType = 'Student'
    AND Author = @Author
    AND BookTitle = @BookTitle
);
GO

CREATE FUNCTION GetPublishersWithTotalPagesGreaterThan
(
    @TotalPages INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT Publisher
    FROM Books
    GROUP BY Publisher
    HAVING SUM(Pages) > @TotalPages
);
GO

CREATE FUNCTION GetMostPopularAuthorForStudents
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1 Author, COUNT(*) AS BookCount
    FROM Library
    WHERE BorrowerType = 'Student'
    GROUP BY Author
    ORDER BY COUNT(*) DESC
);
GO

CREATE FUNCTION GetBooksBorrowedByTeachersAndStudents
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT BookTitle
    FROM Library
    WHERE BorrowerType IN ('Teacher', 'Student')
    GROUP BY BookTitle
    HAVING COUNT(DISTINCT BorrowerType) = 2
);
GO

CREATE FUNCTION GetStudentsWithNoBooks
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    
    SELECT @Count = COUNT(DISTINCT StudentID)
    FROM Students
    WHERE StudentID NOT IN (SELECT DISTINCT StudentID FROM Library);
    
    RETURN @Count;
END;
GO

CREATE FUNCTION GetLibrariansAndBooksIssued
RETURNS TABLE
AS
RETURN
(
    SELECT LibrarianName, COUNT(*) AS BooksIssued
    FROM Library
    WHERE BorrowerType = 'Student' OR BorrowerType = 'Teacher'
    GROUP BY LibrarianName
);
GO
