-- 1. ���������� ����� �� �������� �������� � ������� ��������
USE dz
GO
CREATE PROCEDURE ShowBooksByTopicDescending
    @TopicPattern NVARCHAR(50)
AS
BEGIN
    SELECT * FROM Books
    WHERE Topic LIKE '%' + @TopicPattern + '%'
    ORDER BY Title DESC;
END;
GO

-- 2. ������� ���������� ����, � ������� �� ������� ���� �������
CREATE PROCEDURE CountBooksWithoutPublishDate
AS
BEGIN
    SELECT COUNT(*) FROM Books WHERE PublishDate IS NULL;
END;
GO

CREATE PROCEDURE CountBooksWithoutPublishDateAlt
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Books WHERE PublishDate IS NULL;
    SELECT @Count;
END;
GO

-- 3. ���������� ������� ���� ��� ���� ��� ���� �������
CREATE PROCEDURE SetPublishDateToCurrent
AS
BEGIN
    UPDATE Books
    SET PublishDate = GETDATE()
    WHERE PublishDate IS NULL;
END;
GO

-- 4. ��� ���� ���������� ������������ ���������� ���� �������, �� 4 ���� ������
CREATE PROCEDURE SetPublishDateByPublisherWithOffset
    @PublisherPattern NVARCHAR(50)
AS
BEGIN
    UPDATE Books
    SET PublishDate = DATEADD(YEAR, 4, PublishDate)
    WHERE Publisher LIKE '%' + @PublisherPattern + '%';
END;
GO

-- 5. ��� ����, ����� ������� ������ ��������� ������, ���������� ����� ����������� 15000
CREATE PROCEDURE SetCopiesForHighPrintRun
    @PrintRun INT
AS
BEGIN
    UPDATE Books
    SET Copies = 15000
    WHERE PrintRun > @PrintRun;
END;
GO

-- 6. ������� �����, � ������� ���������� ������� ����� 0
CREATE PROCEDURE RemoveBooksWithZeroPages
AS
BEGIN
    DELETE FROM Books WHERE Pages = 0;
END;
GO

-- 7. ������� ����� �� �������� ��������, ������� ���������� ����� N ��� �����
CREATE PROCEDURE RemoveOldBooksByTopic
    @TopicPattern NVARCHAR(50),
    @Years INT
AS
BEGIN
    DELETE FROM Books
    WHERE Topic LIKE '%' + @TopicPattern + '%'
    AND DATEDIFF(YEAR, PublishDate, GETDATE()) > @Years;
END;
GO

-- 8. ���������� ����� ������� ����� �� �������� ������� (����� �������� ����������)
CREATE PROCEDURE FindCheapestBookFromTopics
    @Price MONEY OUTPUT
AS
BEGIN
    SELECT TOP 1 @Price = Price
    FROM Books
    WHERE Topic IN ('����������������', '���� ������ ������-������', '�����������')
    ORDER BY Price ASC;
END;
GO

-- 8.1. ���������� ����� ������� ����� �� �������� ������� (����� �������� ���������� � �������� RETURN)
CREATE PROCEDURE FindCheapestBookFromTopicsReturn
    @Price MONEY OUTPUT
RETURNS MONEY
AS
BEGIN
    SELECT TOP 1 @Price = Price
    FROM Books
    WHERE Topic IN ('����������������', '���� ������ ������-������', '�����������')
    ORDER BY Price ASC;
    RETURN @Price;
END;
GO

-- 9. ���������� ������������ � ���������� ����������� �������
CREATE PROCEDURE FindTopPublisherByNewBooks
AS
BEGIN
    SELECT TOP 1 Publisher, COUNT(*) AS BookCount
    FROM Books
    WHERE PublishDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY Publisher
    ORDER BY COUNT(*) DESC;
END;
GO

-- 9.1. ���������� ������������ � ���������� ����������� ������� (�������������� ������)
CREATE PROCEDURE FindTopPublisherByNewBooksAlt
AS
BEGIN
    DECLARE @Publisher NVARCHAR(255);
    SELECT TOP 1 @Publisher = Publisher
    FROM Books
    WHERE PublishDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY Publisher
    ORDER BY COUNT(*) DESC;
    SELECT @Publisher AS Publisher;
END;
GO

-- 10. ���������� ����� ������� ����� ������������ BHV
CREATE PROCEDURE FindMostExpensiveBookBHV
AS
BEGIN
    SELECT TOP 1 * FROM Books
    WHERE Publisher = 'BHV'
    ORDER BY Price DESC;
END;
GO

-- 10.1. ���������� ����� ������� ����� ������������ BHV (�������������� ������)
CREATE PROCEDURE FindMostExpensiveBookBHVAlt
AS
BEGIN
    DECLARE @Price MONEY;
    SELECT TOP 1 @Price = Price
    FROM Books
    WHERE Publisher = 'BHV'
    ORDER BY Price DESC;
    SELECT @Price AS Price;
END;
GO
