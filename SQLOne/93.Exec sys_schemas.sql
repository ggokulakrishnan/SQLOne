--													Sri Krishnarpanam
 
--Understanding "sys.schemas"
 
--Create a database specifying Primary and Transaction Log files
USE master;
GO
 
--01. List all the DB along with Data and Log file size
SELECT    name, size, size*1.0/128 AS [Size in MBs]
FROM    sys.master_files;
 
--OP:
--name                  size	Size in MBs
--SQLOneSchemaDB_DATA	512		4.000000
--SQLOneSchemaDB_LOG	1536	12.000000
 
--01. List only DB Name and Size
Exec sp_databases -- Defined in SQL2005
 
--OP:
--DATABASE_NAME   DATABASE_SIZE     REMARKS
--SQLOneSchemaDB  16384             NULL
 
--01. List DB's with additional info (name, db_size, owner, dbid, created, status, compatibility_level)
Exec sp_helpdb -- Defined in SQL2005
 
--OP:
--name            db_size           owner				dbid	created     compatibility_level     status                                                                                                                                                                                                                                                                                                                             
--SQLOneSchemaDB  16.00 MB			Vinayagar\Maruthi	16      Feb 15 2016 110                     Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled
 
--01. List only DB names
EXEC sp_msForEachDB 'PRINT ''?''' -- Undocumented procedure in SQL Server
--OP:
--SQLOneSchemaDB 

--01. Check if DB exists
IF DB_ID(N'SQLOneSchemaDB') IS NOT NULL
	PRINT 'SQLOneSchemaDB is present in this SQL Instance';
ELSE
	PRINT 'SQLOneSchemaDB is present in this SQL Instance, kindly proceed with DB Creation';

--01. Check if DB 'SQLOneSchemaDB' if exists delete the database else raise appropriate error message
USE master;
GO

IF DB_ID(N'SQLOneSchemaDB') IS NOT NULL
BEGIN TRY
	DROP DATABASE SQLOneSchemaDB;
	PRINT 'SQLOneSchemaDB is present in this SQL Instance and it is deleted successfully';
END TRY
BEGIN CATCH	
	PRINT 'Error deleting SQLOneSchemaDB, below could be the possible reasons ...';
	PRINT 'ErrorNumber = '		+ CONVERT(VARCHAR(10), ISNULL(ERROR_NUMBER(), '')) +
		  ', ErrorSeverity = '	+ CONVERT(VARCHAR(10), ISNULL(ERROR_SEVERITY(), '')) + 
		  ', ErrorState = '		+ CONVERT(VARCHAR(10), ISNULL(ERROR_STATE(), '')) +
		  ', ErrorProcedure = ' + CONVERT(VARCHAR(50), ISNULL(ERROR_PROCEDURE(), 'N/A')) +
		  ', ErrorLine = '		+ CONVERT(VARCHAR(10), ISNULL(ERROR_LINE(), '')) +
		  CHAR(13) + CHAR(10) +
		  'ErrorMessage = '	+ CONVERT(VARCHAR(99), ISNULL(ERROR_MESSAGE(), ''));
END CATCH
GO
 
USE SQLOneSchemaDB;
GO 

--01. Verify the option settings (Collation, Is Trustworthy, Is DB Chaining Enabled)
SELECT name, collation_name, is_trustworthy_on, is_db_chaining_on FROM sys.databases WHERE name = N'SQLOneSchemaDB'

--OP:
--name				collation_name					is_trustworthy_on	is_db_chaining_on
--SQLOneSchemaDB	SQL_Latin1_General_CP1_CI_AS	0					0
 
USE master;
GO
 
CREATE DATABASE SQLOneSchemaDB
ON
	( NAME			= SQLOneSchemaDB_DATA,
    FILENAME		= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\SQLOneSchemaDBData.mdf',
    SIZE			= 4,
    MAXSIZE			= 5,
    FILEGROWTH		= 5 )
LOG ON
	( NAME			= SQLOneSchemaDB_LOG,
    FILENAME		= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\SQLOneSchemaDBLog.ldf',
    SIZE			= 12 MB,
    MAXSIZE			= 14 MB,
    FILEGROWTH		= 5 MB );
GO
 
--OP: Command(s) completed successfully.
 
--Link: https://msdn.microsoft.com/en-us/library/ms365315.aspx
 
--01. Basics of Create Table:
--    A. Create Table must have Name, DataType for each column.
--    B. It is a good practice to indicate null values are allowed in each columns
--    C. Most of the tables have Primary Key made up of one or more columns
--    D. Primary Key is always unique
--    E. Database engine will enfore the restriction that Primary Key value cannot be repeated in a table
 
--02. Database Engine can be installed in 02 modes (Case Sensitive & Non-Case Sensitive)
--    A. If DB engine is Case Sensitive, objects must always have the same case
--          E.g) Table: ORDERDATA and OrderData are different from each other
--    B. If DB engine is Non-Case Sensitive the 02 tables are considered to be the same tables and the name can
--          be used only once
 
--03. Create a database to contain a table in SQL Instance
USE master;
GO

--PRINT the database if it already exists
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N'SQLOneSchemaDB')
      --DROP DATABASE SQLOneSchemaDB;
      PRINT 'Database ''SQLOneSchemaDB'' is present in this instance'; 
ELSE
      PRINT 'Database ''SQLOneSchemaDB'' is not present in this instance'; 
GO

--OP: Error Message 01:
--Msg 3702, Level 16, State 3, Line 3
--Cannot drop database "SQLOneDB" because it is currently in use.
--Database 'SQLOneDB' dropped successfully !!!

--CREATE a new database SQLOneSchemaDB (Refer above Line No: #29)...

--CREATE a table in database SQLOneSchemaDB
Use SQLOneSchemaDB;
GO

CREATE TABLE dbo.Products (
      ProductID INT PRIMARY KEY NOT NULL
      , ProductName VARCHAR(25) NOT NULL
      , Price MONEY NULL
      , ProductDesc TEXT NULL);
GO
 
SELECT * FROM dbo.Products;
 
--OP: Command(s) completed successfully.
 
--Understanding:
--01. In the above table only columns [Price] & [ProductDesc] can have no data when a row is inserted
--          or changed
--02. (dbo.) using this element is optional, this is called Schema
--03. Schema is a database object who owns the table, if logged in user is an administrator (dbo) is the
--          default schema. (dbo.) stands for database owner
 
 
--01. Create table with Primary Key constraint [Using PRIMARY Key Constraint on a Column]
USE SQLOneSchemaDB;
GO
 
CREATE TABLE dbo.Employee (
      EmpID INT PRIMARY KEY CLUSTERED);
GO   
 
--Understanding:
--01. Here a CLUSTERED index Primary Key will be created in column [EmpID] for table [dbo.Employee]
--02. In this case the constraint name is not specified, hence system supplies a constraint name
 
SELECT * FROM dbo.Employee (NoLock);
 
--02. Foreign Key (From Adv Works consider 02 tables)
--          (a) Sales.SalesPerson
--          (b) Sales.SalesOrderHeader
 
--01(A). Create a new schema in database 'SQLOneSchemaDB' with the name 'Sales'
USE SQLOneSchemaDB;
GO
 
CREATE SCHEMA Sales;
GO
 
--01. A new schema has been created in database 'SQLOneDB'
--02. Schema 'Sales' is an empty schema at this moment since no objects has been
--          moved into 'Sales' schema
 
--01(B). List all schema's in a database (sys.schemas)
 
Use SQLOneSchemaDB;
GO
 
SELECT * FROM sys.schemas;

--OP:
--name	schema_id	principal_id
--Sales	5			1

--01. Except the schema [Sales] all other schema's are created by SQL Server
 
--OP:
/*
name				schema_id	principal_id
dbo					1			1
guest				2			2
INFORMATION_SCHEMA	3			3
sys					4			4
Sales*				5			1
db_owner			16384		16384
db_accessadmin		16385		16385
db_securityadmin	16386		16386
db_ddladmin			16387		16387
db_backupoperator	16389		16389
db_datareader		16390		16390
db_datawriter		16391		16391
db_denydatareader	16392		16392
db_denydatawriter	16393		16393
*/
 
--01(C). Adding a new table in the given schema [Sales]
 
--01. When creating a table we can specify the schema the needs to be located
--02. This can be done by prefixing the Table name with Schema name
--03. A new table 'SchTable' is created in schema 'Sales'
 
Use SQLOneSchemaDB;
GO
 
CREATE TABLE Sales.SchTable (Id INT);
GO
 
SELECT * FROM Sales.SchTable;
 
SELECT * FROM SchTable;
SELECT * FROM dbo.SchTable;

--OP:
/*Error 01:
--Msg 208, Level 16, State 1, Line 1
--Invalid object name 'SchTable'*/
 
--Table 'SchTabls' is present inside schema 'Sales' hence it is not available in dbo.
--    or other schemas
 
SELECT * FROM sys.tables;
SELECT * FROM sys.schemas;
 
--Identify the tables/objects that are inside the schema - 'Sales'
 
USE SQLOneSchemaDB;
GO
 
SELECT	st.name [TableName], st.type_desc [Type Desc], ss.name [Schema Name]
FROM	sys.tables st, sys.schemas ss
WHERE	st.schema_id = ss.schema_id
	AND	ss.name = 'Sales';
GO
 
--OP:
--TableName Type Desc   Schema Name
--SchTable  USER_TABLE  Sales
 
--01(D). Transfer an existing table from one schema to another schema
 
--01. Using ALTER SCHEMA.. TRANSFER.. table from one schema to another schema
--02. Login as 'sa' (sys admin account)
--03. Create a new Schema in 'SQLOneSchemaDB' with name 'SalesTrans'
--04. Use ALTER SCHEMA.. TRANSFER ..
--05. Table 'SchTable' has moved from 'Sales' schema to the new schema 'SalesTrans'
 
--01. Check if database has a schema with the same name which we are planning to create
USE SQLOneSchemaDB;
GO
 
IF EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'SalesTrans')
      PRINT 'Schema ''SalesTrans'' exists in database: ' + DB_NAME();
ELSE
      PRINT 'Schema ''SalesTrans'' is not present in database: ' + DB_NAME();
GO
 
--01. Display the name of the current database
SELECT DB_NAME()
 
USE SQLOneSchemaDB;
GO
 
CREATE SCHEMA SalesTrans;
GO
 
 --01. This will list all the schemas that are in database 'SQLOneSchemaDB'
SELECT * FROM sys.schemas;
GO
 
--01. List all the table in schemas 'Sales' & 'SalesTrans'
SELECT	st.name [TableName], st.type_desc [Type Desc], ss.name [Schema Name]
FROM	sys.tables st, sys.schemas ss
WHERE	st.schema_id = ss.schema_id
	AND	ss.name IN ('Sales', 'SalesTrans');
GO
 
--OP:
--TableName Type Desc   Schema Name
--SchTable  USER_TABLE  Sales
 
--01. Move the table 'SchTable' to new schema 'SalesTrans'
 
USE SQLOneSchemaDB;
GO
 
ALTER SCHEMA SalesTrans TRANSFER Sales.SchTable;
GO
 
USE SQLOneSchemaDB;
GO
 
--01. List all the table in schemas 'Sales' & 'SalesTrans'
SELECT  st.name [TableName], st.type_desc [Type Desc], ss.name [Schema Name]
FROM	sys.tables st, sys.schemas ss
WHERE	st.schema_id = ss.schema_id
	AND	ss.name IN ('Sales', 'SalesTrans');
GO
 
--OP:
--TableName Type Desc   Schema Name
--SchTable  USER_TABLE  SalesTrans

--01. List all the objects in a given schema

--A. Schema is a container
--B. To list all the objects stored in a given schema use sys.objects
--C. List all the objects that are in schema (a) Sales, (b) SalesTrans and (c) dbo
 
 SELECT * FROM sys.objects
 SELECT * FROM sys.schemas

 SELECT	o.name, o.schema_id, o.type_desc, s.name
 FROM	sys.objects o, sys.schemas s
 WHERE	o.schema_id	= s.schema_id
	AND	s.name IN ('Sales', 'SalesTrans', 'dbo');
GO

--01. Default schema for logged in session


 
CREATE TABLE [Sales].[SalesOrderHeader](
      [SalesOrderID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
      [RevisionNumber] [tinyint] NOT NULL,
      [OrderDate] [datetime] NOT NULL,
      [DueDate] [datetime] NOT NULL,
      [ShipDate] [datetime] NULL,
      [Status] [tinyint] NOT NULL,
      --[OnlineOrderFlag] [dbo].[Flag] NOT NULL,
      [SalesOrderNumber]  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID],0),N'*** ERROR ***')),
      --[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
      --[AccountNumber] [dbo].[AccountNumber] NULL,
      [CustomerID] [int] NOT NULL,
      [SalesPersonID] [int] NULL,
      [TerritoryID] [int] NULL,
      [BillToAddressID] [int] NOT NULL,
      [ShipToAddressID] [int] NOT NULL,
      [ShipMethodID] [int] NOT NULL,
      [CreditCardID] [int] NULL,
      [CreditCardApprovalCode] [varchar](15) NULL,
      [CurrencyRateID] [int] NULL,
      [SubTotal] [money] NOT NULL,
      [TaxAmt] [money] NOT NULL,
      [Freight] [money] NOT NULL,
      [TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
      [Comment] [nvarchar](128) NULL,
      [rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
      [ModifiedDate] [datetime] NOT NULL,
CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED
(
      [SalesOrderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
 
GO
 
/*
https://msdn.microsoft.com/en-us/library/ms174979.aspx
https://msdn.microsoft.com/en-us/library/ms365315.aspx
http://dba.fyicenter.com/faq/sql_server_2/Transferring_Tables_from_One_Schema_to_Another.html

 
Repeater Control: http://www.sevenforums.com/themes-styles/50589-no-desktop-background-image.html
SQL Naming Conventions: https://social.msdn.microsoft.com/Forums/sqlserver/en-US/fc76df37-f0ba-4cae-81eb-d73639254821/sql-server-naming-convention?forum=databasedesign
MS Naming Convention: https://msdn.microsoft.com/en-us/library/ms229045.aspx
SQL Server Standards: http://www.isbe.net/ILDS/pdf/SQL_server_standards.pdf
Check DB Exists: http://www.tech-recipes.com/rx/36940/sql-server-check-if-table-or-database-already-exists/
Drop If Exists: https://blogs.msdn.microsoft.com/sqlserverstorageengine/2015/11/03/drop-if-exists-new-thing-in-sql-server-2016/
Schema: http://dba.fyicenter.com/faq/sql_server_2/Transferring_Tables_from_One_Schema_to_Another.html
Mitigation and Contingency: http://www.differencebetween.com/difference-between-mitigation-and-vs-contingency/
							http://www.izenbridge.com/blog/know-the-difference-between-mitigation-plan-and-contingency-plan/
*/

--Error Handling: http://www.aspdotnet-suresh.com/2013/03/exception-handling-in-sql-server-stored.html
--					https://www.simple-talk.com/sql/database-administration/handling-errors-in-sql-server-2012/
-- Error Handling Trans: http://www.sommarskog.se/error_handling/Part1.html
-- Error Handling in SP: http://sqlhints.com/2014/01/25/exception-handling-template-for-stored-procedure-in-sql-server/