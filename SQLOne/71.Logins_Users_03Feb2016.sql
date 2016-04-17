--										Sri Rama Jaya Rama Jaya Jaya Rama

--01. Creating a new SQL Login

--Undestandings:
--01. Is role a collection of Users ?
--		No

--02. What is Role ?
--		Role is a set of permission that acts like a template, we can assign User to a Role and they get 
--		the permissions in that Role
--		User	-->		Role	(User gets all the permissions of that Role)

--03. What are SECURABLES ?
--		We can secure few of the tables from the user (who as db_owner) role, who will have access other wise

 
USE master;
GO
 
CREATE DATABASE DEMODBMP10
ON
	( NAME			= DEMODBMP10_DATA,
    FILENAME		= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP10Data.mdf',
    SIZE			= 4,
    MAXSIZE			= 5,
    FILEGROWTH		= 5 )
LOG ON
	( NAME			= DEMODBMP10_LOG,
    FILENAME		= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\DEMODBMP10Log.ldf',
    SIZE			= 12 MB,
    MAXSIZE			= 14 MB,
    FILEGROWTH		= 5 MB );
GO

-- Create 03 tables in this Database 'DEMODBMP10'

USE DEMODBMP10;
GO

CREATE TABLE dbo.Products (
      ProductID INT PRIMARY KEY NOT NULL
      , ProductName VARCHAR(25) NOT NULL
      , Price MONEY NULL
      , ProductDesc TEXT NULL);
GO
 
SELECT * FROM dbo.Products;
SELECT * FROM Products;
 
-- Same results for the above 02 SELECT statements
-- The owner of this 'Products' table is 'dbo'

USE DEMODBMP10;
GO
 
CREATE TABLE dbo.Employee (
      EmpID INT PRIMARY KEY CLUSTERED);
GO   
 
SELECT * FROM dbo.Employee (NoLock);
SELECT * FROM Employee (NoLock);

-- The owner of this 'Employee' table is 'dbo'

-- Create a new SCHEMA called 'trans' in DEMODBMP10
USE DEMODBMP10;
GO

CREATE SCHEMA trans;
GO

-- Create the table [Transaction] in 'trans' schema
USE DEMODBMP10;
GO

CREATE TABLE trans.[Transaction] (
	TransID		INT
	, ProductID	INT
	, FirstName	VARCHAR(50)
	, LastName	VARCHAR(50)
	, TransDate	DATETIME
	, CostInUSD	MONEY);
GO


-- List all the tables that are in database along with their schema details
SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM sys.tables;
Exec sp_msforeachtable 'print ''?'''

--OP:
/*	TABLE_CATALOG	| TABLE_SCHEMA	| TABLE_NAME	| TABLE_TYPE
	DEMODBMP10		| dbo			| Products		| BASE TABLE
	DEMODBMP10		| dbo			| Employee		| BASE TABLE
	DEMODBMP10		| trans			| Transaction	| BASE TABLE */

-- 'Products' table is having 'dbo' schema
INSERT INTO Products VALUES (1, 'Sandle', 45, 'Sandle Wood Powder');

SELECT * from Products;
SELECT * from dbo.Products;
--OP:
/*	ProductID	ProductName	Price	ProductDesc
	1			Sandle		45.00	Sandle Wood Powder */

EXECUTE AS USER = fooUser
SELECT * FROM dbo.Products
REVERT
SELECT * FROM dbo.Products

--Not working above sample (REVERT / EXECUTE AS USER)

-- List all the Objects that are in database
SELECT * FROM sysobjects

--Understand in Simple terms:
-- LOGIN:- grants principle entry to SQL Server (LOGIN will have access to SERVER)
-- USER:- grants login to a database			(USER will have access to DATABASE)
-- One Login can be associated with many users
--	LOGIN_A		<--	USER_A
--				<-- USER_B
--				<-- USER_C
-- LOGIN is a security principle, to connect to SQL Server a login is required
-- LOGIN being a security principle, permissions are granted to logins. The scope of LOGIN is to the whole database engine
-- To connect to a specific database in the SQL instance LOGIN must be mapped to database USER
-- Permission inside the database are Granted / Denied to the database USER and NOT to LOGIN

--Link: http://blogs.msdn.com/b/lcris/archive/2007/03/23/basic-sql-server-security-concepts-logins-users-and-principals.aspx
-- SQL Server 02 Security realms involved
--		(a) Server
--		(b) Database
-- To get the work done one needs to have access to the SQL Instance and then to the Database
-- Access to server is granted via Login, there are 02 categories of Login
--		(a) SQL Server Authenticated Login
--		(b) Windows Authenticated Login
-- Just having the LOGIN are not enough because work is usually done on a database
-- access to the database is granted via USERS

-- USERS --> LOGIN (Users are mapped to Login)

-- LOGIN is mapped to a USER in database if their SID values are identical
-- Quick Recall:-
-- A. LOGIN provides access to a SERVER
-- B. Futher to get access to a database, the USER mapped to LOGIN must exists in the database
-- C. All Databases in SQL Serve exists as separate REALM, it is an advantage as a database can be detached from an instance
--		and attached to another instance
--		Moving of database from an instance to another will require manual operation for moving the logins
--		Remapping can be done using sp_change_users_login or starting SQL 2005 SP2 a new clause for ALTER USER statement
-- D. Users that are not mapped to a LOGIN as part of database move will be considered as ORPHANED users
-- E. Server Level permissions are assigned to LOGINS
-- F. Database Level permissions are assigned to USERS
-- G. In SQL Server entities (other than LOGIN, USERS) can be granted persmission known as PRINCIPLES
-- H. Principles are classified into:
--		(a) SERVER PRINCIPLE
--		(b) DATABASE PRINCIPLE
-- I. Examples of SERVER PRINCIPLE:
--		(a) server roles
--		(b) Login mapped to Certificate or asymmetric keys
-- J. Examples of DATABASE PRINCIPLES:
--		(a) database roles (fixed and flexible)
--		(b) application roles
--		(c) users mapped to Certificate or asymmetric keys
--		(d) loginless users (CREATE USER .. WITHOUT LOGIN)

--Link: http://blogs.msdn.com/b/lcris/archive/2006/10/24/sql-server-2005-demo-for-enabling-database-impersonation-for-cross-database-access.aspx
--DEMO: (Cross Database Access)

--01. List all LOGIN accounts in SQL Instance
--S		=> SQL Logins
--U		=> Windows Login Accounts
--G		=> Windows GROUP Login Accounts

SELECT		name, type, type_desc, create_date, default_database_name --*
FROM		sys.server_principals
WHERE		type IN ('U', 'S', 'G')
	AND		name NOT LIKE '%##%'
ORDER BY	name, type_desc

--OP:
/*	name						type	type_desc		create_date					default_database_name
	NT AUTHORITY\SYSTEM			U		WINDOWS_LOGIN	2015-12-07 16:43:31.607		master
	NT Service\MSSQLSERVER		U		WINDOWS_LOGIN	2015-12-07 16:43:31.600		master
	NT SERVICE\ReportServer		U		WINDOWS_LOGIN	2015-12-07 16:43:41.683		master
	NT SERVICE\SQLSERVERAGENT	U		WINDOWS_LOGIN	2015-12-07 16:43:32.927		master
	NT SERVICE\SQLWriter		U		WINDOWS_LOGIN	2015-12-07 16:43:31.583		master
	NT SERVICE\Winmgmt			U		WINDOWS_LOGIN	2015-12-07 16:43:31.593		master
	sa							S		SQL_LOGIN		2003-04-08 09:10:35.460		master
	Vinayagar\Maruthi			U		WINDOWS_LOGIN	2015-12-07 16:43:31.560		master */

--Display only SQL Login accounts
SELECT		name, type, type_desc, create_date, default_database_name --*
FROM		sys.server_principals
WHERE		type = 'S'
	AND		name NOT LIKE '%##%'
ORDER BY	name, type_desc

--Diplay only Windows Login accounts
SELECT		name, type, type_desc, create_date, default_database_name --*
FROM		sys.server_principals
WHERE		type = 'U'

--Display Windows Group Login accounts
SELECT		name, type, type_desc, create_date, default_database_name --*
FROM		sys.server_principals
WHERE		type = 'G'

--01. CREATE principles (Alice, Bob, Charles)
USE master;
GO

CREATE LOGIN lgnALICE WITH PASSWORD = 'a1ic3'; 
GO

CREATE LOGIN lgnBOB WITH PASSWORD = 'b0b'; 
GO

CREATE LOGIN lgnCHARLES WITH PASSWORD = 'char13s'; 
GO

--OP: Command(s) completed successfully.

--02. CREATE 02 databases owned by ALICE and BOB
CREATE DATABASE ALICEDBMP01;
GO

CREATE DATABASE BOBDBMP01;
GO

--The logins will not be able to access the database 'ALICEDBMP01' and 'BOBDBMP01'
--OP: The database BOBDBMP01 is not accessible. (ObjectExplorer)

ALTER AUTHORIZATION ON DATABASE::ALICEDBMP01 TO lgnALICE;
GO

ALTER AUTHORIZATION ON DATABASE::BOBDBMP01 TO lgnBOB;
GO

--OP: Command(s) completed successfully.

--03. Adding Charles to Bob's database
SELECT USER_NAME();
--OP: dbo

SELECT SUSER_SNAME();
--OP: Vinayagar\Maruthi

USE BOBDBMP01;
GO

EXECUTE AS LOGIN = 'lgnBOB';
GO

SELECT SUSER_SNAME();
--OP: lgnBOB

CREATE USER usrCHARLES;
GO

--OP: Command(s) completed successfully.

--04. Add USER [Charles] to Bob's Database

USE BOBDBMP01;
GO

execute as login = 'lgnBOB'

-- add charles to bob's database
--
create user lgnCHARLES

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'usrCHARLES')
BEGIN
	CREATE USER lgnCHARLES  FOR LOGIN lgnBOB WITH DEFAULT_SCHEMA = dbo;
END

SELECT * FROM master.dbo.syslogins

CREATE USER urCHARLES
FOR LOGIN lgnBOB
WITH DEFAULT_SCHEMA = dbo;

--Quick Check: Ensure User in the datbase is not mapped to Login 
SELECT  log.loginname ,
        usr.name AS username
FROM    sysusers usr
        INNER JOIN master..syslogins log ON usr.sid = log.sid
WHERE   usr.name = 'usrCHARLES'

SELECT * FROM sysusers
SELECT * FROM master..syslogins







--Understandings:
--Links: https://technet.microsoft.com/en-us/library/aa337562(v=sql.110).aspx
--01. A login is the identity of the person or process that is connecting to an instance of SQL Server
--02. Login is a security principle (which can be authenticted by security system)
--03. Users needs to have a login to connect to a SQL Instance
--04. Login can be created on Windows principle (Domain User / Windows Domain Group)
--05. A Login which is created not based on Windows principle is (SQL Server Login), to use this login type SQL server 
--		must be configured in mixed mode authentication

--06. Login Scope: With security principle, permission is granted to the logins. The scope of the login is to the whole database
--07. To connect a database on an instance of SQL Server the [LOGIN] must be mapped to a database [USER]
--08. Permission inside the database are granted based on database [USER] and NOT the [LOGIN]

--09. Creating a [LOGIN] with Windows Authetication:
--10. Open cmd (Command Prompt) with Run As 'Administrator' and enter the command C:\>net user (enter)
--OP: 
/* 
C:\>net user
User accounts for \\VINAYAGAR
-------------------------------------------------------------------------------
Administrator            Guest                    Maruthi
The command completed successfully.
*/
--11. Here we have 03 logins created in windows, we will use the account [Maruthi] for our demo and 
--	create a login with this name in SQL Server
--12. Create a [LOGIN] for SQL Server by specifying server name and windows domain account name
--13. Here Server Name: (Maruthi) and Windows Domain Account Name: (Vinayagar)

CREATE LOGIN [<domainName>\<loginName>] FROM WINDOWS;
GO

CREATE LOGIN [VINAYAGAR\Maruthi] FROM WINDOWS;
GO

--https://technet.microsoft.com/en-us/library/ms189751(v=sql.110).aspx
--https://technet.microsoft.com/en-us/library/aa337562(v=sql.110).aspx
--http://www.c-sharpcorner.com/UploadFile/dhananjaycoder/create-a-sql-login-user-in-sql-server-2008/
--http://debugmode.net/

--http://superuser.com/questions/344728/list-members-of-a-windows-group-using-command-line
--C:\>WMIC
--wmic:root\cli>/?
--wmic:root\cli>USERACCOUNT


--Verify your default schema

USE master;	-- [master] is where all the SQL Server logins are stored
GO

--01. Create a new login called 'fooLogin' that uses SQL Server Authentication for login mechanism 
--		this login starts with password 'Baz1nga' but the password must be changed after the first login
--		the option MUST_CHANGE option cannot be used when CHECK_EXPIRATION is OFF
--		If CHECK_EXPIRATION is ON then CREATE LOGIN would raise an error
CREATE LOGIN fooLogin 
   WITH PASSWORD = 'Baz1nga' MUST_CHANGE,
   CHECK_EXPIRATION = ON;
GO
--OP: Command(s) completed successfully.

USE master;
GO

DROP LOGIN fooLogin;
GO

--OP: (If login does not exists in this instance)
--Msg 15151, Level 16, State 1, Line 1
--Cannot drop the login 'fooLogin', because it does not exist or you do not have permission.

--(Or)

DECLARE @return INT;
Exec @return = sp_droplogin fooLogin;
PRINT @return;
GO

--OP: (When login 'fooLogin' exists in the instance)
--Command(s) completed successfully. (Or)
--0

--OP: (If login does not exists in this instance)
--Msg 15007, Level 16, State 1, Procedure sp_droplogin, Line 26
--'fooLogin' is not a valid login or you do not have permission.
--1

--01. 'sp_droplogin' internally called DROP LOGIN
--02. 'sp_droplogin' cannot be called with in a user-defined transaction
--03. It always returns an interger as output (0 for Success) and (1 for Failure) 

--Now only a LOGIN is create with the name 'fooLogin' this login will not have access to any database
--	After the login is created, the login can connect to SQL Server it will not have sufficient permission to 
--	perform any useful work

--01. Now add SQL Server login 'fooLogin' to Database 'DEMODBMP10' as user 'fooUser', this user 'fooUser' can now 
--		be added to any server role

--Link: https://msdn.microsoft.com/en-IN/library/ms187750.aspx

USE DEMODBMP10;
GO

CREATE USER fooUser FOR LOGIN fooLogin;
GO

--01. Adding database user to a role

SELECT * FROM sys.database_role_members -- role_principle_id (16384), member_principle_id (1)
SELECT * FROM sys.database_principals	-- 

SELECT		*
FROM		sys.database_role_members rm, sys.database_principals p
WHERE		p.principal_id = rm.role_principal_id
	AND		p.owning_principal_id = rm.member_principal_id	

SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name;

--Link: https://msdn.microsoft.com/en-us/library/ms188659.aspx

--01. List all Server roles (Returns list of server level roles)
Exec sp_helpsrvrole				--ServerRole, Description

--02. Return information about the members who are in server role
Exec sp_helpsrvrolemember		-- ServerRole, MemberName, MemberSID

--03. Displays all the permission of server level role
Exec sp_srvrolepermission		-- ServerRole, Permission

--04. Indicates whether SQL Login is a member of specified server-level role
--		Return Type: 
--		0 - Login is not a member of role
--		1 - Login is member of role
--	 NULL - role or login is not valid, or you do not have permission to view the role	

SELECT USER_ID()				--OP: 1
SELECT USER_NAME(USER_ID())		--OP: dbo
SELECT SUSER_NAME(USER_ID())	--OP: sa
SELECT SUSER_SNAME(USER_SID())	--OP: Vinayagar\Maruthi
SELECT USER_SID()				--OP: 0x0105000000000005150000007FC0B41011F5B931957D3535E8030000
SELECT SUSER_ID()				--OP: 259
SELECT SUSER_SID()				--OP: 0x0105000000000005150000007FC0B41011F5B931957D3535E8030000

SELECT IS_SRVROLEMEMBER ('sysadmin')								--OP: 1 Logged in user 'Vinayagar\Maruthi' is of Server role 'sysadmin'
SELECT IS_SRVROLEMEMBER ('sysadmin', SUSER_SNAME(USER_SID()))		--OP: 1 Logged in user 'Vinayagar\Maruthi' is of Server role 'sysadmin'
SELECT IS_SRVROLEMEMBER ('sysadmin', SUSER_SNAME(USER_SID()))		--OP: 1 Logged in user 'Vinayagar\Maruthi' is of Server role 'sysadmin'
SELECT IS_SRVROLEMEMBER ('sysadmin', N'Vinayagar\Maruthi')			--OP: 1 Logged in user 'Vinayagar\Maruthi' is of Server role 'sysadmin'

--05. 'sys.server_role_members' one row is returned for each memeber of each server-level role
SELECT * FROM sys.server_role_members 

--06. Add login as a member of server role (sp_addsrvrolemember) THIS IS DEPRECIATED
--		Use 'ALTER SERVER ROLE' instead
--		Adding SQL Server login 'fooLogin' to 'sysadmin' fixed server role
--		A. When a login is added to a fixed server role the login gains permission associated with the role
--		B. 'sp_addrolemember' is used to add a login to fixed database or user-defined role
--		C. Return Code (0 - Success) and (1 - Failure)
 
Exec sp_addrolemember 'fooLogin', 'sysadmin';
GO

--07. Removes Windows, SQL Server Login or Group from Server-Level roles (sp_dropsrvrolemember) THIS IS DEPRECIATED
--		Use 'ALTER SERVER ROLE' instead
--		A. Removes login 'fooLogin' from 'sysadmin' fixed server role
--		B. Return (0 - Success) and (1 - Failure)

Exec sp_dropsrvrolemember 'fooLogin', 'sysadmin';
GO

--08. 'CREATE SERVER ROLE' creates a new user defined server rol
--		A. Creating a new server role 'csrSvrRole' that is owned by a login 'fooLogin'
USE master;
GO

CREATE SERVER ROLE csrSvrRole AUTHORIZATION fooLogin;
GO

--		B. Creating a new server role 'csrRole' that is owned by a fixed server role
USE master;
GO

CREATE SERVER ROLE audSvrRole AUTHORIZATION sysadmin;
GO

--09. 'ALTER SERVER ROLE' changes the membership of a server role or changes name of user-defined server role
--		A. Create a new server role with the name 'prdSvrRole'
--		B. Change the name of the server role form 'prdSvrRole' to 'prodSvrRole'
--		C. Adding a SQL login to Server Role
--		D. 

USE master;
GO

CREATE SERVER ROLE prdSvrRole;
GO

USE master;
GO

ALTER SERVER ROLE prdSvrRole WITH NAME = prodSvrRole;
GO

--01. Adding SQL Server login named 'fooLogin' to 'sysadmin' fixed server role
ALTER SERVER ROLE sysadmin ADD MEMBER fooLogin;
GO

--02. Removing SQL Server login name 'fooLogin' from fixed server role
ALTER SERVER ROLE sysadmin DROP MEMBER fooLogin;
GO

--03. GRANT login permission to add logins to user-defined server role
GRANT ALTER ON SERVER ROLE :: prodSvrRole TO fooLogin;
GO

--10. Remove user defined Server Role

USE master;
GO

DROP SERVER ROLE prodSvrRole;
GO

DROP SERVER ROLE audSvrRole;
GO

DROP SERVER ROLE csrSvrRole;
GO

SELECT	SP1.name AS RoleOwner, SP2.name AS ServerRole
FROM	sys.server_principals AS SP1
JOIN	sys.server_principals AS SP2
    ON SP1.principal_id = SP2.owning_principal_id 
ORDER BY SP1.name ;

--11. 'IS_SRVROLEMEMBER' determine membership of server role
--		Resultset:	0 - Login is not a member of role
--					1 - Login is member of role
--				 NULL - role or login is not valid or you do not have permission to view role membership

SELECT IS_SRVROLEMEMBER('sysadmin', 'fooLogin');		--OP: 0 (Login not a member of role)
SELECT IS_SRVROLEMEMBER('sysadmin');					--OP: 1 (Login 'Vinayagar\Maruthi' is member of sysadmin role)

--B. Database user creation

USE master;	-- [master] is where all the SQL Server logins are stored
GO

--01. Create a new login called 'fooLogin' that uses SQL Server Authentication for login mechanism 
--		this login starts with password 'Baz1nga' but the password must be changed after the first login
--		the option MUST_CHANGE option cannot be used when CHECK_EXPIRATION is OFF
--		If CHECK_EXPIRATION is ON then CREATE LOGIN would raise an error
CREATE LOGIN fooLogin 
   WITH PASSWORD = 'Baz1nga' MUST_CHANGE,
   CHECK_EXPIRATION = ON;
GO

--02. Create a database user 'fooUser' for the login 'fooLogin' created above
USE master;
GO

CREATE USER fooUser FOR LOGIN fooLogin;
GO

--01. Change the database context to 'DEMODBMP10'
USE DEMODBMP10;
GO

PRINT USER_NAME();
GO
--OP:
--dbo

SELECT		name, default_schema_name, type
FROM		sys.database_principals
WHERE		type = 'S'


-- Clean up section 
USE master;
GO

--01. Drop the databases that were created for Logins_Users.sql
DROP DATABASE [ALICEDBMP01]
DROP DATABASE [BOBDBMP01]

USE master;
GO

--02. Remove SQL logins that were created for Logins_Users.sql
DROP LOGIN [lgnALICE]
DROP LOGIN [lgnBOB]
DROP LOGIN [lgnCHARLES]