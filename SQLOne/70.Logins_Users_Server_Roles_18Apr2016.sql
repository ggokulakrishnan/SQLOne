-- Sri Rama Jeyam

--About: 
-- A. Create a Login in SQL Server
-- B. Create a user defined Server role (SQL Server 2012 and above)
-- C. Create a User in SQL Server

--Follow Up: Steps to take after you create a login
-- (a) After creating a login, the login can connect to SQL Server, but does not necessarily have sufficient 
--		 permission to perform any useful work. 
-- (b) To have the login join a role, see [https://technet.microsoft.com/en-us/library/ff877886(v=sql.110).aspx]
-- (c) To authorize a login to use a database, see Create a Database User [https://technet.microsoft.com/en-us/library/aa337545(v=sql.110).aspx]
-- (d) To grant a permission to a login, see Grant a Permission to a Principal [https://technet.microsoft.com/en-us/library/ff878066(v=sql.110).aspx]


--Link: https://technet.microsoft.com/en-us/library/ms189751%28v=sql.110%29.aspx?f=255&MSPPError=-2147217396

--01. Create Login with SQL Authentication
------------------------------------------

--01.A Create Login with Password

CREATE LOGIN lgnFoo01 WITH PASSWORD = 'hello';
GO

--01.B Create Login and MUST_CHANGE the password during first time they connect to a server

CREATE LOGIN lgnFoo02 WITH PASSWORD = 'hello' MUST_CHANGE;
GO

--01.C Create Login mapped to a Credential

CREATE LOGIN lgnFoo03 WITH PASSWORD = 'hello',
	CREDENTIAL = CRED01;
GO

--01.D Create Login for a Certificate in master

USE master;
GO
CREATE CERTIFICATE FOOCERT
	WITH SUBJECT	= 'lgnFoo004 Certificate in master Database'
	, EXPIRY_DATE	= '22/12/2018';
GO

CREATE LOGIN lgnFoo04 FROM CERTIFICATE FOOCERT;
GO

--01.E Create Login for a Windows Domain account

CREATE LOGIN [VINAYAGAR\wLgnFoo05] FROM WINDOWS;
GO


--03. About: CREATE USER (Transact-SQL)

--Link: https://technet.microsoft.com/en-us/library/ms173463%28v=sql.105%29.aspx

--Working: (a) Adds a user to the current database

--03.a Create a Server login with the name: lgnAna with a password then create a corresponding user: dbUsrAna 
--		in database DEMODBMP11

USE [master];

CREATE DATABASE DEMODBMP11;

CREATE LOGIN lgnAna
WITH PASSWORD = 'helloAna';

USE DEMODBMP11;

CREATE USER dbUsrAna FOR LOGIN lgnAna;
GO

--B. Create a database user with DEFAULT schema
--		First create a server login of name 'lgnPeter' with Password create a corresponding database user 'dbUsrPeter'
--		corresponding to database DEMODBMP11 with DEFAULT schema 

USE DEMODBMP11;

CREATE SCHEMA Sales;

USE [master];

CREATE LOGIN lgnPeter
WITH PASSWORD = 'helloPeter'

USE DEMODBMP11;

CREATE USER dbUsrPeter FOR LOGIN lgnPeter
WITH DEFAULT_SCHEMA = Sales;
GO

http://dba.stackexchange.com/questions/58848/how-to-create-users-in-sql-server-for-accessing-only-one-database-using-manageme
https://technet.microsoft.com/en-us/library/ms189751%28v=sql.105%29.aspx?f=255&MSPPError=-2147217396
https://technet.microsoft.com/en-us/library/ms173463%28v=sql.105%29.aspx
https://msdn.microsoft.com/en-us/library/ms189121%28v=sql.105%29.aspx
https://support.chartio.com/knowledgebase/granting-table-level-permissions-in-sql-server

--02. List the permissions that can be granted to a user-defined server role in SQL Server 2012 and later editions

--Link: http://searchsqlserver.techtarget.com/feature/Create-a-user-defined-server-role-in-SQL-Server-2012-with-T-SQL-SSMS

USE master
GO

SELECT	 * 
FROM	 sys.fn_builtin_permissions(DEFAULT)            
WHERE	 class_desc IN ('ENDPOINT','LOGIN','SERVER','AVAILABILITY GROUP','SERVER ROLE')            
ORDER BY class_desc, permission_name;
GO

--02.a Create SQL Server login
-- A new user-defined server role is to create or add a new login, which can be 
--	assigned to a new user-defined server role

USE master;
GO

CREATE LOGIN [Brinto] WITH PASSWORD = 'hello',
DEFAULT_DATABASE = [master],
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF;
GO

--03. Create user-defined SQL Server roles using T-SQL query
USE [master];
GO

CREATE SERVER ROLE [JuniorDBA] AUTHORIZATION [sa]
GO

ALTER SERVER ROLE [JuniorDBA] ADD MEMBER [Brinto]
GO

--04. Grant permissions to user-defined SQL Server roles using T-SQL query (Assigining Permission)

--04.a Add respective permissions to the user-defined server role created using the above T-SQL code
--04.b Ex. Grant the permissions ALTER TRACE, CONNECT SQL, CREATE ANY DATABASE, 
--		VIEW ANY DATABASE, VIEW ANY DEFINITION and VIEW SERVER STATE to the above sample server role [JuniorDBA].

USE [master]
GO

GRANT ALTER TRACE TO [JuniorDBA];
GRANT CONNECT SQL TO [JuniorDBA];
GRANT CREATE ANY DATABASE TO [JuniorDBA];
GRANT VIEW ANY DATABASE TO [JuniorDBA];
GRANT VIEW ANY DEFINITION TO [JuniorDBA];
GRANT VIEW SERVER STATE TO [JuniorDBA];

--05. Verify permissions

--05.a  Verify permissions assigned to the newly created server role by executing the T-SQL 
--			query below in a new query window
--05.b Since the user has VIEW SERVER STATE permissions, you can get the result from the dynamic management view

SELECT SUSER_SNAME()
EXECUTE AS LOGIN = 'Brinto'

SELECT SUSER_SNAME()
SELECT * FROM sys.dm_os_windows_info

REVERT
SELECT SUSER_SNAME()


-- .sql CleanUp Actions

-- A. Create a Login in SQL Server

USE master;
GO

DROP LOGIN [VINAYAGAR\wLgnFoo05];
DROP LOGIN lgnFoo04;
DROP LOGIN lgnFoo03;
DROP LOGIN lgnFoo02;
DROP LOGIN lgnFoo01;

-- B. Create a user defined Server role (SQL Server 2012 and above)
USE master;
GO

DROP SERVER ROLE [JuniorDBA];
DROP LOGIN [Brinto];