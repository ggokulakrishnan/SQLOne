SELECT * FROM sys.sysdatabases -- (returns 12 Columns), they are for old metadata table that exists in SQL2000, they are still there for compatibility reasons
SELECT * FROM sys.databases --(returns 56 Columns), SQL2005

Exec sp_databases -- Defined in SQL2005
Exec sp_helpdb -- Defined in SQL2005
EXEC sp_msForEachDB 'PRINT ''?''' -- Undocumented procedure in SQL Server

SELECT	name, physical_name AS current_file_location
FROM	sys.master_files  

--Find the Schema and Owner of a database object
SELECT  
    so.[name] AS [Object] 
  , sch.[name] AS [Schema] 
  , USER_NAME(COALESCE(so.[principal_id], sch.[principal_id])) AS [Owner] 
  , type_desc AS [ObjectType] 
FROM sys.objects so 
  JOIN sys.schemas sch 
    ON so.[schema_id] = sch.[schema_id] 
WHERE [type] IN ('U', 'P');

--(or)

SELECT  
    [name] AS [schema]  
  , [schema_id] 
  , USER_NAME(principal_id) [Owner] 
FROM sys.schemas

--Detatch a database
sp_detatch_db <<DatabaseName>> 

--	List all the tables that are in database along with their schema details
SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM sys.tables;
Exec sp_msforeachtable 'print ''?'''

-- List all the Objects that are in database
SELECT * FROM sysobjects

--OP: 
/* AF: Aggregate function (CLR)
C: CHECK constraint
D: Default or DEFAULT constraint
F: FOREIGN KEY constraint
L: Log
FN: Scalar function
FS: Assembly (CLR) scalar-function
FT: Assembly (CLR) table-valued function
IF: In-lined table-function
IT: Internal table
P: Stored procedure
PC: Assembly (CLR) stored-procedure
PK: PRIMARY KEY constraint (type is K)
RF: Replication filter stored procedure
S: System table
SN: Synonym
SQ: Service queue
TA: Assembly (CLR) DML trigger
TF: Table function
TR: SQL DML Trigger
TT: Table type
U: User table
UQ: UNIQUE constraint (type is K)
V: View
X: Extended stored procedure
*/

--01. List all LOGIN accounts in SQL Instance
--S		=> SQL Logins
--U		=> Windows Login Accounts
--G		=> Windows GROUP Login Accounts

SELECT		name, type, type_desc, create_date, default_database_name --*
FROM		sys.server_principals
WHERE		type IN ('U', 'S', 'G')
	AND		name NOT LIKE '%##%'
ORDER BY	name, type_desc

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