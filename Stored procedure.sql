-- Stored Procedure




use Library




-- SP "Factorial". SP calculates the factorial of a given number. (5! = 1 * 2 * 3 * 4 * 5 = 120 ) (0! = 1) (the factorial of a negative number does not exist).


CREATE OR ALTER Procedure sp_1
@number as bigint
AS
BEGIN
  declare @factorial int=1
  while @number>0
  Begin
   set @factorial = @number *  @factorial
   set @number=@number-1
  End
  select @factorial as Factorial
END




EXEC sp_1 4




-- SP "Lazy Students." SP displays students who never took books in the library and through the output parameter returns the number of these students.


CREATE OR ALTER Procedure sp_2
@countofstudent int output
AS
BEGIN
  select 
  Library.dbo.Students.FirstName,
  Library.dbo.Students.LastName
  from
  Library.dbo.Students
  Inner Join Library.dbo.S_Cards
  ON
  Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student 
  Inner Join Library.dbo.Books
  ON
  Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
  where
  Library.dbo.S_Cards.DateOut IS NULL
  AND
  Library.dbo.S_Cards.DateIn IS NULL 
  set @countofstudent =@@ROWCOUNT
END




Declare @count as int
EXEC sp_2 @count output
Select @count as StudentCount




--  SP "Books on the criteria." SP displays a list of books that matching criterion: the author's name, surname, subject, category. In addition, the list should be sorted by the column number specified in the 5th parameter, in the direction indicated in parameter 6. Columns: 1) book identifier, 2) book title, 3) surname and name of the author, 4) topic, 5) category.


CREATE OR ALTER Procedure sp_3
AS
BEGIN
  select 
  Library.dbo.Books.Id,
  Library.dbo.Books.[Name] AS [Books Name],
  Library.dbo.Authors.FirstName AS [Authors FirstName],
  Library.dbo.Authors.LastName AS [Authors LastName],
  Library.dbo.Themes.[Name] AS [Thema name],
  Library.dbo.Categories.[Name] AS [Category name]
  from
  Library.dbo.Books
  Inner Join Library.dbo.Authors
  ON
  Library.dbo.Books.Id_Author=Library.dbo.Authors.Id
  Inner Join Library.dbo.Themes
  ON
  Library.dbo.Themes.Id=Library.dbo.Books.Id_Themes
  Inner Join Library.dbo.Categories
  ON
  Library.dbo.Categories.Id=Library.dbo.Books.Id_Category
  Order by Library.dbo.Categories.[Name] DESC
END




EXEC sp_3




--X SP "Adding a student." SP adds a student and a group. If the group with this name exists, specify the Id of the group in Id_Group. If this name does not exist: first add the group and then the student. Note that the group names are stored in uppercase, but no one guarantees that the user will give the name in uppercase.


CREATE OR ALTER Procedure sp_4
@GroupID int output,
@GroupName NVARCHAR(30),
@Id_Facuilty int,
@StudentsId int,
@StudentsFirstName NVARCHAR(30),
@StudentsLastName NVARCHAR(30),
@Id_Group int,
@Term int
AS
BEGIN
   Declare @nGroupName as nvarchar(max)
   select @nGroupName
   Declare @nID as INT
   select @nID

  IF (EXISTS
  (
   SELECT 
   *FROM Groups
   WHERE [Name]=@nGroupName
  ))
    BEGIN
	 INSERT INTO Library.dbo.Students(Id, FirstName, LastName, Id_Group, Term) 
     VALUES(@StudentsId, @StudentsFirstName, @StudentsLastName, @Id_Group, @Term)
    END
   ELSE
    BEGIN
	 INSERT INTO Library.dbo.Groups(Id, [Name], Id_Faculty) 
     VALUES(@GroupID, UPPER(@GroupName), @Id_Facuilty) 
	 INSERT INTO Library.dbo.Students(Id, FirstName, LastName, Id_Group, Term) 
     VALUES(@StudentsId, @StudentsFirstName, @StudentsLastName, @GroupID, @Term)
	END
	SELECT* from Students
    SELECT* from Groups
END




EXEC sp_4 11, 'FSda ', 2,    26, 'cc', 'bb', 11, 4


EXEC sp_4 10, 'FSda ', 2,    29, 'cc2', 'bb2', 10, 4





-- SP "Purchase of popular books." SP chooses the top 5 most popular books (among students and teachers simultaneously) and buys another 3 copies of every book.


CREATE OR ALTER Procedure sp_5
@BuyQuantity as int
AS
BEGIN
  IF (EXISTS
  (
  Select
  Library.dbo.Books.Id,
  Library.dbo.Books.Name,
  Library.dbo.Books.Quantity
  from
  Library.dbo.Teachers 
  Inner Join Library.dbo.T_Cards
  ON
  Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
  Inner Join Library.dbo.Books
  ON
  Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
  Where Books.Quantity>=@BuyQuantity
  INTERSECT
  Select
  Library.dbo.Books.Id,
  Library.dbo.Books.Name,
  Library.dbo.Books.Quantity
  from
  Library.dbo.Students 
  Inner Join Library.dbo.S_Cards
  ON
  Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
  Inner Join Library.dbo.Books
  ON
  Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
  Where Library.dbo.Books.Quantity>=@BuyQuantity
  ))
  BEGIN
    Update  Library.dbo.Books
    Set Library.dbo.Books.Quantity=Library.dbo.Books.Quantity-@BuyQuantity
    Where Library.dbo.Books.Quantity>=@BuyQuantity
  END
END




EXEC sp_5 3   




Select
Library.dbo.Books.Id,
Library.dbo.Books.Name,
Library.dbo.Books.Quantity
from
Library.dbo.Teachers 
Inner Join Library.dbo.T_Cards
ON
Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
Inner Join Library.dbo.Books
ON
Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
INTERSECT
Select
Library.dbo.Books.Id,
Library.dbo.Books.Name,
Library.dbo.Books.Quantity
from
Library.dbo.Students 
Inner Join Library.dbo.S_Cards
ON
Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
Inner Join Library.dbo.Books
ON
Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book









-- SP "Getting rid of unpopular books." SP chooses top 5 non-popular books and gives half to another educational institution.


CREATE OR ALTER Procedure sp_6
AS
BEGIN
  IF (EXISTS
  (
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Teachers 
   Inner Join Library.dbo.T_Cards
   ON
   Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
  Except
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Students 
   Inner Join Library.dbo.S_Cards
   ON
   Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
 Union
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Students 
   Inner Join Library.dbo.S_Cards
   ON
   Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
  Except
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Teachers 
   Inner Join Library.dbo.T_Cards
   ON
   Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
  ))
  BEGIN
    Update  Library.dbo.Books
    Set Library.dbo.Books.Quantity=Library.dbo.Books.Quantity/2
    Where Library.dbo.Books.Quantity>=1
  END
END




EXEC sp_6




   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Teachers 
   Inner Join Library.dbo.T_Cards
   ON
   Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
  Except
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Students 
   Inner Join Library.dbo.S_Cards
   ON
   Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
 Union
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Students 
   Inner Join Library.dbo.S_Cards
   ON
   Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
  Except
   Select TOP(5)
   Library.dbo.Books.Id,
   Library.dbo.Books.Name,
   Library.dbo.Books.Quantity
   from
   Library.dbo.Teachers 
   Inner Join Library.dbo.T_Cards
   ON
   Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
   Inner Join Library.dbo.Books
   ON
   Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book




--X SP "A student takes a book." SP gets Id of a student and Id of a book. Check quantity of books in table Books (if quantity > 0). Check how many books student has now. If 3-4 books, then we issue a warning, and if there are already 5 books, then we do not give him a new book. If student can take this book, then add row in table S_Cards and update column quantity in table Books.


CREATE OR ALTER Procedure sp_7
@StudentsId int,
@BookId int
AS
SET NOCOUNT ON
BEGIN
    IF(EXISTS
	(
     Select *
     from
     Library.dbo.Students 
     Inner Join Library.dbo.S_Cards
     ON
     Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
     Where 
     Library.dbo.Students.Id=@StudentsId
	 AND
	 Library.dbo.Books.Id=@BookId
    )
    )
	BEGIN
	IF(EXISTS
	(
	 Select
	 count(*)
     from
     Library.dbo.Students 
     Inner Join Library.dbo.S_Cards
     ON
     Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
	 where
     Library.dbo.Students.Id=@StudentsId
     AND 
     Library.dbo.Books.Id=@BookId
	 group by      
	 Library.DBO.Students.Id
	 Having 
	 COUNT(*)=3
	 OR
	 COUNT(*)<=4
	 )
	 )
	 BEGIN
	   SELECT 'You are approaching the book withdrawal limit' AS [NOTIFICATION]
	   UPDATE Library.dbo.Books
       SET Library.dbo.Books.Quantity = Library.dbo.Books.Quantity-1
       WHERE 
	   Library.dbo.Books.Quantity>0

	   SELECT *FROM Books
       where Books.Id=@BookId
	 END
	 IF(EXISTS
	(
	 Select
	 count(*)
     from
     Library.dbo.Students 
     Inner Join Library.dbo.S_Cards
     ON
     Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
	 where    
	 Library.dbo.Students.Id=@StudentsId
     AND 
     Library.dbo.Books.Id=@BookId
	 group by      
	 Library.DBO.Students.Id
	 Having 
	 COUNT(*)>=5
	 )
	 )
	 BEGIN
	  SELECT 'You have exceeded the book withdrawal limit' AS [NOTIFICATION]
	 END
	END
	ELSE
	BEGIN
	  SELECT 'Error' AS [NOTIFICATION]
	END
END
	



EXEC sp_7 16, 10


SELECT *FROM S_Cards


SELECT *FROM Books


SELECT *FROM Students
where Students.Id=16


SELECT *FROM Books
where Books.Id=10



-- SP "Teacher takes the book."


CREATE OR ALTER Procedure sp_8
@TeachersId int,
@BookId int
AS
SET NOCOUNT ON
BEGIN
    IF(EXISTS
	(
     Select *
     from
     Library.dbo.Teachers 
     Inner Join Library.dbo.T_Cards
     ON
     Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
     Where 
     Library.dbo.Teachers.Id=@TeachersId
	 AND
	 Library.dbo.Books.Id=@BookId
    )
    )
	BEGIN
	IF(EXISTS
	(
	 Select
	 count(*)
     from
     Library.dbo.Teachers 
     Inner Join Library.dbo.T_Cards
     ON
     Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
	 where
     Library.dbo.Teachers.Id=@TeachersId
     AND 
     Library.dbo.Books.Id=@BookId
	 group by      
	 Library.DBO.Teachers.Id
	 Having 
	 COUNT(*)=3
	 OR
	 COUNT(*)<=4
	 )
	 )
	 BEGIN
	   SELECT 'You are approaching the book withdrawal limit' AS [NOTIFICATION]
	   UPDATE Library.dbo.Books
       SET Library.dbo.Books.Quantity = Library.dbo.Books.Quantity-1
       WHERE 
	   Library.dbo.Books.Quantity>0

	   SELECT *FROM Books
       where Books.Id=@BookId
	 END
	 IF(EXISTS
	(
	 Select
	 count(*)
     from
     Library.dbo.Teachers 
     Inner Join Library.dbo.T_Cards
     ON
     Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
	 where    
	 Library.dbo.Teachers.Id=@TeachersId
     AND 
     Library.dbo.Books.Id=@BookId
	 group by      
	 Library.DBO.Teachers.Id
	 Having 
	 COUNT(*)>=5
	 )
	 )
	 BEGIN
	  SELECT 'You have exceeded the book withdrawal limit' AS [NOTIFICATION]
	 END
	END
	ELSE
	BEGIN
	
	  SELECT 'Error' AS [NOTIFICATION]
	END

END




EXEC sp_8 6, 10


SELECT *FROM T_Cards


SELECT *FROM Books


SELECT *FROM Teachers
where Teachers.Id=6


SELECT *FROM Books
where Books.Id=10




-- SP "The student returns the book." SP receives Student's Id and Book's Id. In the table S_Cards information is entered about the return of the book. Also you need add quantity in table Books. If the student has kept the book for more than a year, then he is fined.


CREATE OR ALTER Procedure sp_9
@StudentsId int,
@BookId int
AS
SET NOCOUNT ON
BEGIN
    IF(EXISTS
	(
     Select *
     from
     Library.dbo.Students 
     Inner Join Library.dbo.S_Cards
     ON
     Library.dbo.Students.Id=Library.dbo.S_Cards.Id_Student
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.S_Cards.Id_Book
     Where 
     Library.dbo.Students.Id=@StudentsId
	 AND
	 Library.dbo.Books.Id=@BookId
    )
    )
	BEGIN
	    UPDATE Library.dbo.Books
        SET Library.dbo.Books.Quantity = Library.dbo.Books.Quantity+1
       
	    UPDATE Library.dbo.S_Cards
		SET Library.dbo.S_Cards.DateOut =GETDATE()
		where 
		Library.dbo.S_Cards.DateOut IS NULL
		OR
		Library.dbo.S_Cards.DateOut <  GETDATE()
	END
END


EXEC sp_9 16, 10


SELECT *FROM S_Cards
where 
S_Cards.Id_Student=16
AND
S_Cards.Id_Book=10


SELECT *FROM Books


SELECT *FROM Students
where Students.Id=16


SELECT *FROM Books
where Books.Id=10




-- SP "Teacher returns book".


CREATE OR ALTER Procedure sp_10
@TeachersId int,
@BookId int
AS
SET NOCOUNT ON
BEGIN
    IF(EXISTS
	(
     Select *
     from
     Library.dbo.Teachers 
     Inner Join Library.dbo.T_Cards
     ON
     Library.dbo.Teachers.Id=Library.dbo.T_Cards.Id_Teacher
     Inner Join Library.dbo.Books
     ON
     Library.dbo.Books.Id=Library.dbo.T_Cards.Id_Book
     Where 
     Library.dbo.Teachers.Id=@TeachersId
	 AND
	 Library.dbo.Books.Id=@BookId
    )
    )
	BEGIN
	    UPDATE Library.dbo.Books
        SET Library.dbo.Books.Quantity = Library.dbo.Books.Quantity+1
       
	    UPDATE Library.dbo.T_Cards
		SET Library.dbo.T_Cards.DateOut =GETDATE()
		where 
		Library.dbo.T_Cards.DateOut IS NULL
		OR
		Library.dbo.T_Cards.DateOut <  GETDATE()
	END

END




EXEC sp_10 6, 10


SELECT *FROM T_Cards
where 
T_Cards.Id_Teacher=6
AND
T_Cards.Id_Book=10



SELECT *FROM Teachers
where Teachers.Id=6


SELECT *FROM Books
where Books.Id=10
