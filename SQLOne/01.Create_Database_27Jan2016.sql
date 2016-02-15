--							||| Krishna Ya Samarpanam |||

- ** Do not run the script un monitored **

--01. List all databases in SQL Server --

-- Both of them return the metadata related to the database hosted in the instance
-- In SQL Server 2005 System Catalog View were introduced which is the most prefered way of working with the SQL Server meta data
-- These are view which return much less information compared to catalog view, they are called compatibility views
-- Link: http://www.sqlservergeeks.com/sql-server-sys-databases-vs-sys-sysdatabases/
SELECT * FROM sys.sysdatabases -- (returns 12 Columns), they are for old metadata table that exists in SQL2000, they are still there for compatibility reasons
SELECT * FROM sys.databases --(returns 56 Columns), SQL2005 

Exec sp_databases -- Defined in SQL2005
Exec sp_helpdb -- Defined in SQL2005
EXEC sp_msForEachDB 'PRINT ''?''' -- Undocumented procedure in SQL Server

--Link: https://msdn.microsoft.com/en-us/library/ms176061.aspx
--		https://msdn.microsoft.com/en-IN/library/ms186312.aspx

USE master;
GO;
CREATE DATABASE DEMODBMP01;
GO
--OP: Command(s) completed successfully.
--Undestandings:
--01. Since the CREATE DATABASE doesnot have any file specific item. The primary database file size is as that of the MODEL database primary file
--02. The transaction log file is set to larger value: < 512KB or 25% more that that of the primary file
--03. Since MAXSIZE is not specified the filesize can grow to fill all available disk space

--Verifying the created database file and size
-- Verify the database files and sizes
SELECT	name, size, size*1.0/128 AS [Size in MBs] 
FROM	sys.master_files
WHERE	name = N'DEMODBMP01';

SELECT	name, size, size*1.0/128 AS [Size in MBs] 
FROM	sys.master_files
WHERE	name IN ('DEMODBMP01', 'modeldev', 'DEMODBMP01_log', 'modellog');
GO

--OP of the above query (where primary data file size = model db size and log file is 25% more or < 512): 
--name				size	Size in MBs
---------------------------------------
--modeldev			392		3.062500
--modellog			64		0.500000
--DEMODBMP01		392		3.062500
--DEMODBMP01_log	98		0.765625

--Path where the Primary Data and Log files are created in server
SELECT	name, physical_name AS current_file_location
FROM	sys.master_files 
WHERE	name LIKE ('DEMODBMP01%');

--Method (B): Create a database specifying Primary and Transaction Log files
USE master;
GO

CREATE DATABASE DEMODBMP02
ON
(	NAME		= DEMODBMP02_DATA,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP02Data.mdf',
	SIZE		= 4,
	MAXSIZE		= 5,
	FILEGROWTH	= 5 )
LOG ON
(	NAME		= DEMODBMP02_LOG,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP02Log.ldf',
	SIZE		= 12 MB,
	MAXSIZE		= 14 MB,
	FILEGROWTH	= 5 MB );
GO

--OP: Command(s) completed successfully.

--Undestandings:
--01. In the above CREATE DATABASE the keyword PRIMARY is not used the first file 'DEMODBMP02Data.mdf' will be taken as the PRIMARY file
--02. Neither MB / KB is specified in SIZE, MAXSIZE.. parameters, it uses MB as default
--03. FILEGROWTH: Is the automatic growth, the amount of space added to the file every time a new space is required. 
--			03.A. The value can be specified in MB, GB, TB, KB or (%) [1% is nearest to 64KB]
--			03.B. If Number is specified with out a suffix the default is MB		
--			03.C. A value of 0 indicates automatic growth is Off and no additional space is allowed
--			04.D. If FILEGROWTH is not specified, the default value is 1MB for datafile and 10% for logfiles

--Remarks to know:
--01. master database to be backedup when ever a user database is CREATED, MODIFIED, DROPPED
--02. CREATE DATABASE must always run in autocommit mode (the default is transaction management mode)
--03. Internally SQL Server uses the below steps while creating the database
--			03.A. SQL Server uses a copy of the model database to initialize the database and metadata
--			03.B. A Service borker GUID is assigned to a database
--			03.C. Database engine fills rest of the database with empty pages, except that has internal data
--04. A max of 32,767 databases can be created per instance starting SQL Server 2008 R2 Ed
--05. Each database will have a owner and owner is the one who creates the database
--06. The owner can be changed by using [sp_changedbowner]

--Method (C): Create a database with multiple Primary and Transaction Log files

USE master;
GO

CREATE DATABASE DEMODBMP03
ON
PRIMARY
	(NAME		= DEMODBMP03_DATA,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP03Data.mdf',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 MB),
	(NAME		= DEMODBMP03A_DATA,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP03AData.ndf',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 MB),
	(NAME		= DEMODBMP03B_DATA,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP03BData.ndf',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 MB)
LOG ON
	(NAME		= DEMODBMP03A_LOG,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP03ALog.ldf',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 MB),
	(NAME		= DEMODBMP03B_LOG,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP03BLog.ldf',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 MB);
GO

--OP: Command(s) completed successfully.

--Undestandings:
--01. 03 data files are created each of 04 MB and 02 log files are created each of 04 MB
--02. The PRIMARY file is the first file in the list and it is explicitly with the key word PRIMARY
--03. The Transaction log files are specified with LOG ON keyword

SELECT	name, size, size*1.0/128 AS [Size in MBs] 
FROM	sys.master_files
WHERE	name LIKE ('DEMODBMP03%')
UNION ALL
SELECT	name, size, size*1.0/128 AS [Size in MBs] 
FROM	sys.master_files
WHERE	name LIKE ('model%');
GO

--Method (D): Create a database with file groups
USE master;
GO
CREATE DATABASE DEMODBMP04
ON PRIMARY
	(NAME		= 'DEMODBMP04PRIMARY_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04PriData.mdf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % ), -- 64KB + 64KB = 128KB ~ 2%
	(NAME		= 'DEMODBMP04APRIMARY_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04APriData.ndf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % ),
FILEGROUP DEMOFILEGROUP01
	(NAME		= 'DEMODBMP04BFG01DEMO_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04BFG01Data.ndf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % ), 
	(NAME		= 'DEMODBMP04CFG01DEMO_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04CFG01Data.ndf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % ),
FILEGROUP DEMOFILEGROUP02
	(NAME		= 'DEMODBMP04DFG02DEMO_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04DFG02Data.ndf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % ), 
	(NAME		= 'DEMODBMP04EFG02DEMO_DATA',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04EFG02Data.ndf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % )
LOG ON
	(NAME		= 'DEMODBMP04_LOG',
	 FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\DEMODBMP04Log.ldf',
	 MAXSIZE	= 4 MB,
	 FILEGROWTH	= 2 % );
GO

--OP: Command(s) completed successfully.

--Undestandings:
--01. The primary group has 02 files 'DEMODBMP04PriData' and 'DEMODBMP04APriData'
--02. The file growth increment is 2 %
--03. Filegroup named 'DEMOFILEGROUP01' has 02 files 'DEMODBMP04BFG01Data' and 'DEMODBMP04CFG01Data'
--04. Filegroup named 'DEMOFILEGROUP02' has 02 files 'DEMODBMP04DFG01Data' and 'DEMODBMP04EFG01Data'
--05. Here the data and the log files are placed in different disk to improve the performance

--Method (E): Attaching a database
USE master;
GO
--Detatch the database DEMODBMP04
sp_detach_db DEMODBMP04;
GO
--Attach the database DEMODBMP04
CREATE DATABASE DEMODBMP04
ON (FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP04PriData.mdf')
FOR ATTACH;
GO

--OP: Command(s) completed successfully.

--Undestandings:
--01. Detatch the database using build in stored procedure [sp_detach_db] and attach using [FOR ATTACH] clause
--02. Database 'DEMODBMP04' had multiple files since the path of the files are not changed since they were created, hence specifying
--		only the PRIMARY file in the FOR ATTACH clause is sufficient

--Method (E.01): Attaching a database when file paths are changed
USE master;
GO

sp_detach_db DEMODBMP04;
GO

CREATE DATABASE DEMODBMP04
ON	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04PriData.mdf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04APriData.ndf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04BFG01Data.ndf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04CFG01Data.ndf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04DFG02Data.ndf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\04\DEMODBMP04EFG02Data.ndf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\04\DEMODBMP04Log.ldf')
FOR ATTACH;
GO

--OP: Command(s) completed successfully.

--Method (F): Creating a database snapshot (READONLY)

USE master;
GO
CREATE DATABASE DEMODDBMP04SS 
ON
	(NAME = 'DEMODBMP04PRIMARY_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04PriData.ss'),
	(NAME = 'DEMODBMP04APRIMARY_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04APriData.ss'),
	(NAME = 'DEMODBMP04BFG01DEMO_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04BFG01Data.ss'),
	(NAME = 'DEMODBMP04CFG01DEMO_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04CFG01Data.ss'),
	(NAME = 'DEMODBMP04DFG02DEMO_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04DFG02Data.ss'),
	(NAME = 'DEMODBMP04EFG02DEMO_DATA', FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04EFG02Data.ss')
AS SNAPSHOT OF DEMODBMP04;
GO

--Errors:
--Msg 5133, Level 16, State 1, Line 1
--Directory lookup for the file "D:\Projects\DemoSQL\ADWorks2012OLTPDB\Snapshot\DEMODBMP04PriData.ss" 
--	failed with the operating system error 2(The system cannot find the file specified.).

--Resolution: The folder 'Snapshot' should be created and should be available

--Undestandings:
--01. Snapshot database is READ-ONLY hence a log file cannot be specified
--02. Every file in the source database has to be specified and filegroups are not required
--03. Name should be the same name that was used during the source database creation (mismatch in NAME snapshot cannot be taken)

--Method (G): Creating a database with Collation, Trustworthy and DB_Chaining Options
USE master;
GO

--If database exists DROP the database
IF DB_ID(N'DEMODBMP05') IS NOT NULL
	DROP DATABASE DEMODBMP05;
GO

CREATE DATABASE DEMODBMP05
COLLATE French_CI_AI
WITH TRUSTWORTHY ON, DB_CHAINING ON;
GO

--Verify the option settings
SELECT name, collation_name, is_trustworthy_on, is_db_chaining_on FROM sys.databases WHERE name = N'DEMODBMP05'

--Understandings:
--01. Avoid setting database to TRUSTWORTHY as much as possible
--02. By default TRUSTWORTHY is set to OFF, to enabled you must be a member of sysadmin server role
--03. Situations needed: (i) CLR Integration Security (Malicious Assemblies) (ii) TSQL created with EXECUTE AS Clause
--Links:	http://sqlity.net/en/1653/the-trustworthy-database-property-explained-part-1/
--			https://msdn.microsoft.com/en-us/library/ms187861.aspx
--			http://stackoverflow.com/questions/27006432/security-risks-of-setting-trustworthy-on-in-sql-server-2012

--04: DB Chaininig: When DB_Chaining is enabled on multiple databases, objects share the ownership. Permission checks are
--		skipped if objects are with in the same schema
--Links:	http://glennaitchison.blogspot.in/2012/01/sql-server-2008-database-chaining.html
--			https://msdn.microsoft.com/en-us/library/bb669059%28v=vs.110%29.aspx
--			https://www.mssqltips.com/sqlservertip/1778/ownership-chaining-in-sql-server-security-feature-or-security-risk/
--			https://www.mssqltips.com/sqlservertip/1782/understanding-cross-database-ownership-chaining-in-sql-server/
	
--Method (H): Attaching a Full Text Catalog that has been moved

--Check if FULL TEXT is installed in the server
SELECT SERVERPROPERTY('IsFullTextInstalled');
GO
--OP: 1 (FULL TEXT) Installed 

USE master;
GO

CREATE DATABASE DEMODBMP06
ON
(	NAME		= DEMODBMP06_DATA,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP06Data.mdf',
	SIZE		= 4,
	MAXSIZE		= 5,
	FILEGROWTH	= 5 )
LOG ON
(	NAME		= DEMODBMP06_LOG,
	FILENAME	= 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\DEMODBMP06Log.ldf',
	SIZE		= 12 MB,
	MAXSIZE		= 14 MB,
	FILEGROWTH	= 5 MB );
GO

USE DEMODBMP06;
GO

CREATE TABLE dbo.Persons
(
ID int IDENTITY(1,1) PRIMARY KEY,
LastName varchar(255) NOT NULL,
FirstName varchar(255),
Address varchar(255),
City varchar(255)
);
GO

-- the starting value for IDENTITY is 1, and it will increment by 1 for each new record
-- to specify that the "ID" column should start at value 10 and increment by 5, change it to IDENTITY(10,5).

INSERT INTO dbo.Persons (FirstName, LastName, Address, City) VALUES ('Lars', 'Monsen', '01 Street', 'Chennai');
INSERT INTO dbo.Persons (FirstName, LastName, Address, City) VALUES ('John', 'Peter', '02 Street', 'Bangalore');
INSERT INTO dbo.Persons (FirstName, LastName, Address, City) VALUES ('Emma', 'Haris', '03 Street', 'Hyderabad');
INSERT INTO dbo.Persons (FirstName, LastName, Address, City) VALUES ('Philip', 'Abraham', '04 Street', 'Coimbatore');

SELECT * FROM dbo.Persons;
SELECT COUNT(1) As [RowCount] FROM dbo.Persons (NoLock);

CREATE TABLE Persons_AudTrail
(
ID int IDENTITY(1,1) PRIMARY KEY,
LastName varchar(255) NOT NULL,
FirstName varchar(255),
Address varchar(255),
City varchar(255)
);
GO
-- If no owner is specified when the schema is created (the use of the AUTHORIZATION key word will set the owner), 
--	then the user creating the schema will be the owner.

--Find Schema and Owner for a database object
SELECT  
    so.[name] AS [Object] 
  , sch.[name] AS [Schema] 
  , USER_NAME(COALESCE(so.[principal_id], sch.[principal_id])) AS [Owner] 
  , type_desc AS [ObjectType] 
FROM sys.objects so 
  JOIN sys.schemas sch 
    ON so.[schema_id] = sch.[schema_id] 
WHERE [type] IN ('U', 'P');

--Full Text Catalog has been created
--For Catalog creation Link: http://blog.sqlauthority.com/2008/09/05/sql-server-creating-full-text-catalog-and-index/

SELECT	ID, FirstName, LastName, Address, City
FROM	dbo.Persons
WHERE	FREETEXT(*, 'Coimbatore');

--Physically move the fill text context to the new location

USE master;
GO

--Detach the DEMODBMP06 database that has full text catalog created
sp_detach_db DEMODBMP06;
GO

--Physically move the Full text catalog file to the new location assuming there is no change to data and log files
CREATE DATABASE DEMODBMP06
ON
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP06Data.mdf'),
	(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\DEMODBMP06Log.ldf')
	--(FILENAME = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\FTCatalogs\DEMODBMP06') [NOT SUPPORED SINCE SQL2008]
FOR ATTACH;
GO

--Error:
--Msg 5120, Level 16, State 101, Line 1
--Unable to open the physical file "D:\Projects\DemoSQL\ADWorks2012OLTPDB\FTCatalogs\DEMODBMP06". Operating system error 2: "2(The system cannot find the file specified.)".

--Solution:
--	Ensure that physical path exists

--Undesrtandings:

--01. Full-text catalog had a complete architecture change in 2008 & above and that's why this option is 
--		removed and NOT necessary 
--02. Important Beginning with SQL Server 2008, a full-text catalog is a virtual object and does not belong 
--		to any filegroup. A full-text catalog is a logical concept that refers to a group of full-text indexes. 
--03. Permission: To create Full Text Catalog user must be a member of db_owner or db_ddladmin roles

USE DEMODBMP06;
GO

CREATE FULLTEXT CATALOG FTCatalog_TSQL AS DEFAULT;
GO

CREATE FULLTEXT INDEX ON dbo.Persons_AudTrail(LastName,FirstName,Address,City) KEY INDEX PK__Persons___3214EC273EEBA967;
GO

--Link: https://msdn.microsoft.com/en-us/library/ms189520%28v=SQL.100%29.aspx

--Error:
--Msg 7670, Level 16, State 1, Line 1
--Column 'ID' cannot be used for full-text search because it is not a character-based, XML, image or varbinary(max) type column.

--Solution: Character based columns to be included

--Method (I): Filestream and FileGroup 
USE master;
GO

--Get the SQL Server data path
DECLARE @data_path nvarchar(256);
DECLARE @log_path  nvarchar(256);

SET @data_path = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
                  FROM master.sys.master_files
                  WHERE database_id = 1 AND file_id = 1);
SELECT @data_path;

SELECT @data_path = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\';
SELECT @log_path  = 'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\';

PRINT 'Data Path: ' + @data_path +  CHAR(13) + 'Log Path:  ' + @log_path;
--(Or)
PRINT 'Data Path: ' + @data_path +  CHAR(10) + 'Log Path:  ' + @log_path;
--PRINT ''' + A + '''

--With dynamic SQL Create the database
EXECUTE ('CREATE DATABASE DEMODBMP07
ON PRIMARY (
	NAME		= DEMODBMP07_Data,
	FILENAME	= ''' + @data_path + 'DEMODBMP07Data.mdf'',
	SIZE		= 4 MB,
	MAXSIZE		= 5 MB,
	FILEGROWTH	= 2 % ),
FILEGROUP fgfsPhotos CONTAINS FILESTREAM DEFAULT (
	NAME		= FSPHOTO01,
	FILENAME	= ''D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP07\FSPHOTOS01'',
	--SIZE and FILEGROWTH should not be specified, if they are then error will be generated
	MAXSIZE		= 3 MB ),
	(NAME		= FSPHOTO02,
	FILENAME	= ''D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP07\FSPHOTOS02'',
	MAXSIZE		= 2 MB ),
FILEGROUP fgfsResumes CONTAINS FILESTREAM (
	NAME		= FSRESUMES01,
	FILENAME	= ''D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP07\FSRESUMES01'',
	MAXSIZE		= 2 MB )
LOG ON (
	NAME		= DEMODBMP07_Log,
	FILENAME	= ''' + @log_path + 'FileStreamDB_log.ldf'',
	SIZE		= 5 MB,
	MAXSIZE		= 25 MB,
	FILEGROWTH	= 5 MB)'
	);
GO	 

--OP: (The below error message will be displayed)
--Msg 5591, Level 16, State 1, Line 1
--FILESTREAM feature is disabled.

--(Sub Topic) Enable and Configure FILESTREAM
--Before we start using FileStream in SQLServer, it must be enabled at instance level
-- (IMP) FILESTREAM can not be enabled in 32 BIT version SQL Server running on 64 BIT OS

--01.This Feature has been available since SQL Server 2008
--02.This FILESTREAM feature allows user to store BLOBs in NTFS file system instead of the database
--03.By default this feature is Disabled
--04.Starting SQL Server 2008 one can store BLOBs (Images, Videos, Word, Excel, PDF, MP3 ..) in NTFS FileSystem 
--		rather than database

--Permission / Roles:
-----------------------
--In order to enable this permission user must be a member of SYSADMIN / SERVERADMIN fixed server role

--01. Steps to enable FILESTEAM configuration using TSQL

USE master;
Go

EXEC sp_configure 'show advanced options';
GO

EXEC sp_configure filestream_access_level, 1;
GO
--OP: Configuration option 'filestream access level' changed from 0 to 1. Run the RECONFIGURE statement to install.

RECONFIGURE
GO
--Error:
--Msg 5593, Level 16, State 1, Line 1
--FILESTREAM feature is not supported on WoW64. The feature is disabled.

RECONFIGURE WITH OVERRIDE
GO

SELECT * from sys.configurations WHERE name like 'filestream %'

--https://www.mssqltips.com/sqlservertip/1489/using-filestream-to-store-blobs-in-the-ntfs-file-system-in-sql-server-2008/

--Check if File Stream Access Level is enabled

--01. From SQL Server 2012 and above this query will list all the databases 
--		which have non-transactional access enabled on them, i.e, FileStream.
SELECT DB_NAME(database_id) [DB_Name],directory_name [FileStream_DirectoryName]
    FROM  sys.database_filestream_options
    WHERE non_transacted_access != 0;

--01. To check if already a filegroup for FILESTREAM available [look in sys.data_spaces]
SELECT * FROM sys.data_spaces WHERE TYPE = 'FD';

--01. To check if the filegroup has any file for FILESTREAM [look in sys.database_files]
SELECT * FROM sys.database_files WHERE TYPE = 2;

--01. To check if File Stream is Enabled at Instance level
SELECT SERVERPROPERTY ('FilestreamEffectiveLevel');

--Results: (match with run_value)
--0	=> Disables FILESTREAM support for this instance.
--1 => Enables FILESTREAM for Transact-SQL access.
--2 => Enables FILESTREAM for Transact-SQL and Win32 streaming access.

--02. (Alternate Method) To check if File Stream is Enabled at Instance level
--		Column to refer: 'run_value'
Exec sp_configure 'filestream access level';
GO

--03. (Alternate Method) To check if File Stream is Enabled at Instance level
--		Column to refer: 'value_in_use'
SELECT * FROM sys.configurations WHERE name = 'filestream access level';

--04. (Alternate Method) Examine the status of FILESTREAM support on the database instance
SELECT	SERVERPROPERTY ('FilestreamShareName') ShareName
		,SERVERPROPERTY ('FilestreamConfiguredLevel') ConfiguredLevel
		,SERVERPROPERTY ('FilestreamEffectiveLevel') EffectiveLevel


--Method (J): Create Database FILESTREAM and filegroup with multiple files

--01. Create a database 'DEMODBMP08'
--02. Database contains 01 row filegroup and 01 'FILESTREAM' filegroup
--03. The 'FILESTREAM' group contains 02 files FS1 and FS2
--04. The datbase is altered to add 03rd file FS3 to the FILESTREAM filegroup

USE master;
GO

CREATE DATABASE DEMODBMP08
CONTAINMENT = NONE
ON PRIMARY (
	NAME		= N'DEMODBMP08_Data'
	, FILENAME	= N'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Data\DEMODBMP08Data.mdf'
	, SIZE		= 5 MB
	, MAXSIZE	= 6 -- or UNLIMITED
	, FILEGROWTH= 1 MB )
	, 
FILEGROUP [FS] CONTAINS FILESTREAM DEFAULT (
	NAME		= N'FS01'
	, FILENAME	= N'D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP08\FS01'
	, MAXSIZE	= UNLIMITED )
	, (
	NAME		= N'FS02'
	, FILENAME	= N'D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP08\FS02'
	, MAXSIZE	= 5MB )
LOG ON (
	NAME		= N'DEMODBMP08_Log'
	, FILENAME	= N'D:\Projects\DemoSQL\ADWorks2012OLTPDB\Log\DEMODBMP08Log.ldf'
	, SIZE		= 12 MB
	, MAXSIZE	= 15MB
	, FILEGROWTH= 1 MB );
GO


--01. Use ALTER database to add 03rd file FS03 to the FILESTREAM filegroup [FS]

ALTER DATABASE [DEMODBMP08]
ADD FILE (
	NAME		= N'FS03'
	, FILENAME	= N'D:\Projects\DemoSQL\ADWorks2012OLTPDB\FS\DEMODBMP08\FS03'
	, MAXSIZE	= 2MB )
TO FILEGROUP [FS];
GO

-- ** FILESTREAM (I and J) sections unable to validate due to system restriction

