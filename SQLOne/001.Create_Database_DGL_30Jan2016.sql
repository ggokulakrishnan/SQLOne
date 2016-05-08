--							||| Krishna Ya Samarpanam |||

--01. Create a database [SQLOneDB] in the specified path
--02. The DB (i.e. the data file) can grow up to a size of 50 MB when 

USE master;
GO

CREATE DATABASE SQLOneDB
ON
(	NAME = SQLOneDB_Dat,
	FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\SQLOneDBData.mdf',
	SIZE = 8,			-- ??? If no suffix is specified it will consider the size in MB's as default
	MAXSIZE = 10,		-- ??? Difference between [SIZE, MAXSIZE and FILEGROWTH)
	FILEGROWTH = 2 )	-- ???
LOG ON
(	NAME = SQLOneDB_Log,
	FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\SQLOneDBLog.ldf',
	SIZE = 8MB,
	MAXSIZE = 5MB,
	FILEGROWTH = 2MB );
GO

--01. Drop an existing database
/*
USE master;
GO

DROP DATABASE SQLOneDB;
GO
*/

--01. Create a table in [SQLOneDB] database with the name [TestTable]
--02. The table will have a computed column, Primary and Identity Key

USE SQLOneDB;
GO
 
CREATE TABLE dbo.TestTable (
	ColA INT IDENTITY PRIMARY KEY,
	ColB INT NOT NULL,
	ColC AS (ColA + ColB) * 2);
GO

--01. Drop the table from database [SQLOneDB]
/*
Use master;
GO

DROP TABLE dbo.TestTable;
GO
*/

--01. Use DBCC command to reset the value of IDENTITY column
 
USE SQLOneDB;
GO

DBCC CHECKIDENT ('dbo.TestTable', RESEED, 0);
GO

--Understanding:
--RESEED: 0 [current identity value '1']
--RESEED: 1 [current identity value '2']

--01. SELECT statement with RAND (Random Number) and GUID generation

SELECT * FROM dbo.TestTable (NoLock);
SELECT RAND(100), RAND(), RAND(), (RAND() + 0.95), NEWID();

--01. DELETE data from table [TestTable]
DELETE FROM dbo.TestTable;
GO

--01. INSERT values to table [TestTable]
INSERT INTO dbo.TestTable (ColB) VALUES (RAND() + 0.95);

--01. Get the SIZE of MDF and LDF file of the Current database in KB and MB
SELECT	[file_id], [type], type_desc, data_space_id, [name], physical_name, [state],
	state_desc, size, size * 8 / 1024.00 AS [Size in MB]
FROM	sys.database_files AS DF;
GO

--OP: 
--size Size in MB
--1280 10.0000000
--640 5.0000000
 
--01. Simple WHILE Condition to iterate until the condition is met
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <= 5)
BEGIN
	PRINT @intFlag
	SET @intFlag = @intFlag + 1
END;
GO

--01. SELECT Statements
SELECT * FROM dbo.TestTable (NoLock);
SELECT ColA, ColB, ColC FROM dbo.TestTable (NoLock);
SELECT COUNT(1) FROM dbo.TestTable (NoLock);

--01. Use WHILE loop to populate the table [TestTable] with 5K rows
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <= 5000)
BEGIN
	INSERT INTO dbo.TestTable (ColB) VALUES (RAND() + 0.95)
	SET @intFlag = @intFlag + 1
END;
GO
 
--01. Check and DROP table [T1] from a database 
IF OBJECT_ID ('dbo.T1', 'U') IS NOT NULL
DROP TABLE dbo.T1;
GO

--01. Create a table to INSERT DEFAULT values
CREATE TABLE dbo.T1 (
	column_1 AS 'Computed column ' + column_2,
	column_2 varchar(30)
	CONSTRAINT default_name DEFAULT ('my column default'),
	column_3 rowversion,
	column_4 varchar(40) NULL );
GO

--01. INSERT statement options and use of 'DEFAULT VALUES' key word
INSERT INTO dbo.T1 (column_4) VALUES ('Explicit value');
INSERT INTO dbo.T1 (column_2, column_4) VALUES ('Explicit value', 'Explicit value');
INSERT INTO dbo.T1 (column_2) VALUES ('Explicit value');
INSERT INTO T1 DEFAULT VALUES;
GO

SELECT column_1, column_2, column_3, column_4 FROM dbo.T1;
GO			-- ??? What is the use of GO statment in SQL and how the interpreter / SQL Engine will understand

--01. Understanding FILES and FILEGROUPS
--https://www.simple-talk.com/sql/database-administration/sql-server-database-growth-and-autogrowth-settings/
