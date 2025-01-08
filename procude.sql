-- 1. Отобразить книги по заданной тематике в порядке убывания
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

-- 2. Вывести количество книг, у которых не указана дата издания
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

-- 3. Проставить текущую дату для книг без даты издания
CREATE PROCEDURE SetPublishDateToCurrent
AS
BEGIN
    UPDATE Books
    SET PublishDate = GETDATE()
    WHERE PublishDate IS NULL;
END;
GO

-- 4. Для книг указанного издательства установить дату издания, на 4 года больше
CREATE PROCEDURE SetPublishDateByPublisherWithOffset
    @PublisherPattern NVARCHAR(50)
AS
BEGIN
    UPDATE Books
    SET PublishDate = DATEADD(YEAR, 4, PublishDate)
    WHERE Publisher LIKE '%' + @PublisherPattern + '%';
END;
GO

-- 5. Для книг, тираж которых больше заданного тиража, проставить число экземпляров 15000
CREATE PROCEDURE SetCopiesForHighPrintRun
    @PrintRun INT
AS
BEGIN
    UPDATE Books
    SET Copies = 15000
    WHERE PrintRun > @PrintRun;
END;
GO

-- 6. Удалить книги, у которых количество страниц равно 0
CREATE PROCEDURE RemoveBooksWithZeroPages
AS
BEGIN
    DELETE FROM Books WHERE Pages = 0;
END;
GO

-- 7. Удалить книги по заданной тематике, которые издавались более N лет назад
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

-- 8. Отобразить самую дешевую книгу из заданных тематик (через выходную переменную)
CREATE PROCEDURE FindCheapestBookFromTopics
    @Price MONEY OUTPUT
AS
BEGIN
    SELECT TOP 1 @Price = Price
    FROM Books
    WHERE Topic IN ('Программирование', 'Базы данных клиент-сервер', 'Мультимедиа')
    ORDER BY Price ASC;
END;
GO

-- 8.1. Отобразить самую дешевую книгу из заданных тематик (через выходную переменную и оператор RETURN)
CREATE PROCEDURE FindCheapestBookFromTopicsReturn
    @Price MONEY OUTPUT
RETURNS MONEY
AS
BEGIN
    SELECT TOP 1 @Price = Price
    FROM Books
    WHERE Topic IN ('Программирование', 'Базы данных клиент-сервер', 'Мультимедиа')
    ORDER BY Price ASC;
    RETURN @Price;
END;
GO

-- 9. Отобразить издательство с наибольшим количеством новинок
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

-- 9.1. Отобразить издательство с наибольшим количеством новинок (альтернативный способ)
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

-- 10. Отобразить самую дорогую книгу издательства BHV
CREATE PROCEDURE FindMostExpensiveBookBHV
AS
BEGIN
    SELECT TOP 1 * FROM Books
    WHERE Publisher = 'BHV'
    ORDER BY Price DESC;
END;
GO

-- 10.1. Отобразить самую дорогую книгу издательства BHV (альтернативный способ)
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
