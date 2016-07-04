
-- SKA !!!

--Source:	http://sqlperformance.com/2013/01/t-sql-queries/generate-a-set-1
--			http://sqlhints.com/2015/06/21/looping-through-table-records-in-sql-server/

--https://msdn.microsoft.com/en-us/library/ms187893.aspx
--https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/
--http://sqlmag.com/blog/does-using-checksum-ensure-successful-backup
--http://solutioncenter.apexsql.com/verifying-sql-database-backups-automatically/
--http://solutioncenter.apexsql.com/category/sql-backup-management/

--Theory:
---------
/* 01. User of the below server and database role can perform backup action
		- sysadmin [fixed server role]
		- db_owner, db_backupoperator [fixed database roles]  

*/

USE [master];
GO
--OP: Command(s) completed successfully.

CREATE DATABASE ContosoBK
ON 
( NAME = ContosoBK_Data,
    FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\01.Data\ContosoBKData.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = ContosoBK_Log,
    FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\02.Log\ContosoBKLog.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO
--OP: Command(s) completed successfully.

USE [ContosoBK];
GO
--OP: Command(s) completed successfully.

CREATE TABLE Employee (
	ID INT IDENTITY(1, 1) PRIMARY KEY
	, Name NVARCHAR(100)
	, Status TINYINT );
GO

INSERT INTO Employee ([Name], [Status]) VALUES 
	('John', 1)
    , ('Sara', 0)
    , ('Peter', 1)
    , ('Ethan', 1)
    , ('Sam', 0);
GO 

SP_HELPDB [ContosoBK];
GO

/*
name		db_size		owner		dbid	created		status																																																					compatibility_level
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBK	15.00 MB	CTS\263642	10		Jun 29 2016	Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=661, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled	100

--[After 5L rows]
ContosoBK	20.00 MB	CTS\263642	10		Jun 29 2016	Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=661, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled	100

name			fileid	filename								filegroup	size		maxsize		growth		usage
-------------------------------------------------------------------------------------------------------------------------
ContosoBK_Data	1		D:\Users\..\01.Data\ContosoBKData.mdf	PRIMARY		10240 KB	51200 KB	5120 KB		data only
ContosoBK_Log	2		D:\Users\..\02.Log\ContosoBKLog.ldf		NULL		5120 KB		25600 KB	5120 KB		log only

--[After 5L rows]
ContosoBK_Data	1		D:\Users\..\01.Data\ContosoBKData.mdf	PRIMARY		15360 KB	51200 KB	5120 KB		data only
ContosoBK_Log	2		D:\Users\..\02.Log\ContosoBKLog.ldf		NULL		5120 KB		25600 KB	5120 KB		log only
*/

-- or (another alternate option)

SELECT * FROM sys.master_files (NoLock);

SELECT * FROM Employee (NoLock);
SELECT COUNT(1) FROM Employee (NoLock);

-- Populate test data to Employee table
DECLARE @iCount INT = 1
		, @MaxEmpCount INT = 500000 

DECLARE @EmpName NVARCHAR(100)
		, @EmpStatus TINYINT 
 
WHILE(@iCount <= @MaxEmpCount)
BEGIN
   SELECT @EmpName = [Name]
		  , @EmpStatus = [Status]
   FROM Employee WHERE Id = @iCount
 
   INSERT INTO dbo.Employee ([Name], [Status]) VALUES (@EmpName, @EmpStatus);
   
   -- Increment the counter 
   SET @iCount  = @iCount  + 1        
END

--01. DB backup with CHECKSUM

BACKUP DATABASE ContosoBK
 TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBK.bak'  
   WITH CHECKSUM;  
GO

/* OP:
Processed 1816 pages for database 'ContosoBK', file 'ContosoBK_Data' on file 1.
Processed 2 pages for database 'ContosoBK', file 'ContosoBK_Log' on file 1.
BACKUP DATABASE successfully processed 1818 pages in 0.702 seconds (20.224 MB/sec).
*/  

--02. DB backup without CHECKSUM (NO_CHECKSUM)

BACKUP DATABASE ContosoBK
 TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBKNO_CHKSUM.bak'
   WITH NO_CHECKSUM;
GO

/* OP:
Processed 1816 pages for database 'ContosoBK', file 'ContosoBK_Data' on file 1.
Processed 1 pages for database 'ContosoBK', file 'ContosoBK_Log' on file 1.
BACKUP DATABASE successfully processed 1817 pages in 1.148 seconds (12.364 MB/sec).
*/

--03. Complete Database backup
--Source: https://msdn.microsoft.com/en-us/library/ms186865.aspx

BACKUP DATABASE ContosoBK   
 TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBKComplete.bak'
 WITH FORMAT;
GO  

/* OP:
Processed 1816 pages for database 'ContosoBK', file 'ContosoBK_Data' on file 1.
Processed 1 pages for database 'ContosoBK', file 'ContosoBK_Log' on file 1.
BACKUP DATABASE successfully processed 1817 pages in 0.660 seconds (21.508 MB/sec).
*/
 
--04. Backup Database and Log Simple recovery model (To permit log backup, before the full database 
--		backup modify the database to use full recovery model)

--A. Modify the database to use full recovery model
USE master;
GO

ALTER DATABASE ContosoBK
	SET RECOVERY FULL;
GO

--B. Create logical backup devices for Data and Log
USE master;
GO

Exec sp_addumpdevice 'disk'
	, 'ContosoData'
	, 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBackups\ContosoData.bak';
GO

Exec sp_addumpdevice 'disk'
	, 'ContosoLog'
	, 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBackups\ContosoLog.bak';
GO
 
SELECT * FROM sys.backup_devices

--C. Backup the full Contoso Database
BACKUP DATABASE ContosoBK TO ContosoData;
GO 

--D. Backup the Contoso Log
BACKUP LOG ContosoBK TO ContosoLog;
GO

/* OP:
Processed 1816 pages for database 'ContosoBK', file 'ContosoBK_Data' on file 1.
Processed 1 pages for database 'ContosoBK', file 'ContosoBK_Log' on file 1.
BACKUP DATABASE successfully processed 1817 pages in 0.736 seconds (19.287 MB/sec).
Processed 7 pages for database 'ContosoBK', file 'ContosoBK_Log' on file 1.
BACKUP LOG successfully processed 7 pages in 0.233 seconds (0.217 MB/sec).
*/

--E. Creating fullbackup of Secondary file group

-- Creating a database with Primary and Secondary file group

/*
USE [master];
DROP DATABASE [ContosoBKFG];
GO
*/

CREATE DATABASE [ContosoBKFG] ON  PRIMARY ( 
	NAME = N'ContosoBKFGPrm',
	FILENAME = N'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBkFGPrm.mdf'
	, SIZE = 3072 KB		-- ~3MB
	, FILEGROWTH = 1024KB ) -- ~1MB
	
	, FILEGROUP [Secondary] (
	  NAME = N'ContosoBKFGSec'
	, FILENAME = N'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBkFGSec02.ndf'
	, SIZE = 3072KB			-- ~3MB
	, FILEGROWTH = 1024KB ) -- ~1MB

	LOG ON ( 
	NAME = N'ContosoBKFLog'
	, FILENAME = N'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Log\ContosoBKFLog.ldf' 
	, SIZE = 1024KB 
	, FILEGROWTH = 10% )
GO

--OP: Command(s) completed successfully.

SP_HELPDB [ContosoBKFG];
GO

/* OP:
name			db_size	owner		dbid	created			status																																																					compatibility_level
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBKFG	    7.00 MB	CTS\263642	13		Jul  4 2016		Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=661, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled	100

name			fileid	filename																							filegroup	size	maxsize			growth	usage
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBKFGPrm	1		D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBkFGPrm.mdf		PRIMARY		3072 KB	Unlimited		1024 KB	data only
ContosoBKFLog	2		D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Log\ContosoBKFLog.ldf			NULL		1024 KB	2147483648 KB	10%	log only
ContosoBKFGSec	3		D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBkFGSec02.ndf		Secondary	3072 KB	Unlimited		1024 KB	data only
*/

BACKUP DATABASE [ContosoBKFG]
	FILEGROUP = 'ContosoBKFGPrm'
	, FILEGROUP = 'ContosoBKFGSec'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG.bck';
GO

/* Error:
---------
Msg 3027, Level 16, State 1, Line 1
The filegroup "ContosoBKFGPrm" is not part of database "ContosoBKFG".
Msg 3013, Level 16, State 1, Line 1
BACKUP DATABASE is terminating abnormally.
*/

--http://blog.sqlauthority.com/2013/08/15/sql-server-sql-basics-what-are-filegroups-day-9-of-10/
/*Eg.

	CREATE DATABASE RatisCo
	ON PRIMARY
	(NAME = RaticCo_Data, FILENAME = 'C:\SQL\RatisCo_Data1.mdf'),
	FILEGROUP [OrderHist] (NAME = RaticCo_Hist1, FILENAME = 'D:\SQL\RatisCo_Hist1.ndf'),
	 (NAME = RaticCo_Hist2, FILENAME = 'D:\SQL\RatisCo_Hist2.ndf')
	LOG ON
	(NAME = RaticCo_Log, FILENAME = 'E:\SQL\RatisCoLog.ldf')
	GO
*/

/*
USE [master];
GO
DROP DATABASE [ContosoBKFG01];
GO
*/

CREATE DATABASE ContosoBKFG01
ON PRIMARY (	
	NAME = ContosoBKFG01P_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG01.mdf')
, FILEGROUP [SECONDARY] 
	  ( NAME = ContosoBKFG01SA_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG01SA.ndf')
	, (	NAME = ContosoBKFG01SB_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG01SB.ndf')
LOG ON (
	NAME = ContosoBKFG01_Log
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Log\ContosoBKFG01Log.ldf')
GO

--OP: Command(s) completed successfully.

SP_HELPDB [ContosoBKFG01];
GO

/* OP:
name				db_size	owner		dbid	created			status																																																					compatibility_level
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBKFG01	    4.25 MB	CTS\263642	14		Jul  4 2016		Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=661, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled	100

name					fileid	filename								filegroup		size	maxsize			growth		usage
-------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBKFG01P_Data		1		D:\Users\..\Data\ContosoBKFG01.mdf		PRIMARY			1280 KB	Unlimited		1024 KB		data only
ContosoBKFG01_Log		2		D:\Users\..\Log\ContosoBKFG01Log.ldf	NULL			1024 KB	2147483648 KB	10%			log only
ContosoBKFG01SA_Data	3		D:\Users\..\Data\ContosoBKFG01SA.ndf	SECONDARY		1024 KB	Unlimited		1024 KB		data only
ContosoBKFG01SB_Data	4		D:\Users\..\Data\ContosoBKFG01SB.ndf	SECONDARY		1024 KB	Unlimited		1024 KB		data only
*/

-- Take backup of both PRIMARY and SECONDARY file groups in the database 'ContosoBKFG01'
BACKUP DATABASE [ContosoBKFG01]
	FILEGROUP = 'PRIMARY'
	, FILEGROUP = 'SECONDARY'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG01.bck';
GO

/*OP:
------
Processed 160 pages for database 'ContosoBKFG01', file 'ContosoBKFG01P_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG01', file 'ContosoBKFG01SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG01', file 'ContosoBKFG01SB_Data' on file 1.
Processed 3 pages for database 'ContosoBKFG01', file 'ContosoBKFG01_Log' on file 1.
BACKUP DATABASE...FILE=<name> successfully processed 179 pages in 0.467 seconds (2.988 MB/sec).*/

-- Database 'ContosoBKFG02' contains 03 file group PRIMARY, [SECONDARY] and [TERTIARY]

CREATE DATABASE ContosoBKFG02
ON PRIMARY (	
	NAME = ContosoBKFG02P_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG02.mdf')
, FILEGROUP [SECONDARY] 
	  ( NAME = ContosoBKFG02SA_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG02SA.ndf')
	, (	NAME = ContosoBKFG02SB_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG02SB.ndf')
, FILEGROUP [TERTIARY] 
	( NAME = ContosoBKFG02TC_Data
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Data\ContosoBKFG02TA.ndf')
LOG ON (
	NAME = ContosoBKFG02_Log
	, FILENAME = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\04.FileGroup\Log\ContosoBKFG02Log.ldf')
GO
--OP: Command(s) completed successfully.

-- Take backup of 03 file groups PRIMARY, SECONDARY and TERTIARY filegroups of the database 'ContosoBKFG02'
BACKUP DATABASE [ContosoBKFG02]
	FILEGROUP = 'PRIMARY'
	, FILEGROUP = 'SECONDARY'
	, FILEGROUP = 'TERTIARY'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG02PST.bck';
GO

/* OP:
------
Processed 160 pages for database 'ContosoBKFG02', file 'ContosoBKFG02P_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SB_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 3 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE...FILE=<name> successfully processed 187 pages in 0.339 seconds (4.305 MB/sec).
*/

-- Take backup only for 02 file groups SECONDARY and TERTIARY in the database 'ContosoBKFG02'
BACKUP DATABASE [ContosoBKFG02]
	FILEGROUP = 'SECONDARY'
	, FILEGROUP = 'TERTIARY'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG02ST.bck';
GO

/* OP:
------
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SB_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 1 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE...FILE=<name> successfully processed 25 pages in 0.202 seconds (0.964 MB/sec).
*/

-- Take backup only for 01 file group TERTIARY in the database 'ContosoBKFG02'
BACKUP DATABASE [ContosoBKFG02]
	FILEGROUP = 'TERTIARY'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG02T.bck';
GO

/* OP:
------
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 1 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE...FILE=<name> successfully processed 9 pages in 0.208 seconds (0.335 MB/sec).
*/

-- Take backup only for 01 file group PRIMARY in the database 'ContosoBKFG02'
BACKUP DATABASE [ContosoBKFG02]
	FILEGROUP = 'PRIMARY'
	TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG02P.bck';
GO
/* OP:
------
Processed 160 pages for database 'ContosoBKFG02', file 'ContosoBKFG02P_Data' on file 1.
Processed 1 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE...FILE=<name> successfully processed 161 pages in 0.216 seconds (5.823 MB/sec).
*/

-- Creating a differential file backup of the secondary filegroups
-- We will use the database [ContosoBKFG02]
BACKUP DATABASE [ContosoBKFG02]  
   FILEGROUP = 'SECONDARY',  
   FILEGROUP = 'TERTIARY'  
   TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\FileGroupBackup\ContosoBKFG02DiffBkFgST.bck'
   WITH   
      DIFFERENTIAL;
GO

/*OP:
-----
This BACKUP WITH DIFFERENTIAL will be based on more than one file backup. All those file backups must be restored before attempting to restore this differential backup.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SB_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 2 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE...FILE=<name> WITH DIFFERENTIAL successfully processed 26 pages in 0.142 seconds (1.389 MB/sec). */

-- Creating a compressed backup in a new media set

-- (Backing up a complete database and check the backup size) to check the difference in size between FULL and COMPRESSED BK
BACKUP DATABASE [ContosoBKFG02]   
 TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBackups\ContosoBKFG02.bak'
   WITH FORMAT;
GO

/* OP:
------
Processed 160 pages for database 'ContosoBKFG02', file 'ContosoBKFG02P_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SB_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 1 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE successfully processed 185 pages in 0.243 seconds (5.947 MB/sec).
SIZE: 2,141 KB
*/

BACKUP DATABASE [ContosoBKFG02]
 TO DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBackups\ContosoBKFG02CMPBK.bak'
WITH   
   FORMAT,   
   COMPRESSION;  

/* OP:
------
Processed 160 pages for database 'ContosoBKFG02', file 'ContosoBKFG02P_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SA_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02SB_Data' on file 1.
Processed 8 pages for database 'ContosoBKFG02', file 'ContosoBKFG02TC_Data' on file 1.
Processed 1 pages for database 'ContosoBKFG02', file 'ContosoBKFG02_Log' on file 1.
BACKUP DATABASE successfully processed 185 pages in 0.256 seconds (5.645 MB/sec).
SIZE: 141 KB
*/

--... Continue Here
--https://msdn.microsoft.com/en-us/library/ms186865.aspx
--https://www.mssqltips.com/sqlservertutorial/122/retore-sql-server-database-to-different-filenames-and-locations/
--http://www.sqlrecoverysoftware.net/blog/sql-database-recovery-model.html
--http://sqlmag.com/blog/does-using-checksum-ensure-successful-backup
--https://msdn.microsoft.com/en-us/library/ms186865.aspx
--http://sqlmag.com/blog/does-using-checksum-ensure-successful-backup
--https://msdn.microsoft.com/en-us/library/ms186865.aspx
--http://blog.sqlauthority.com/2009/06/01/sql-server-list-all-objects-created-on-all-filegroups-in-database/
--http://blog.sqlauthority.com/2013/08/15/sql-server-sql-basics-what-are-filegroups-day-9-of-10/
--http://www.sqlrecoverysoftware.net/blog/sql-database-recovery-model.html
--https://www.mssqltips.com/sqlservertutorial/122/retore-sql-server-database-to-different-filenames-and-locations/
--https://msdn.microsoft.com/en-us/library/ms186865.aspx


--03. DB RESTORE WITH CHECKSUM

RESTORE DATABASE ContosoBKCSM
 FROM DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBK.bak'
   WITH CHECKSUM;
GO
 
/*OP:
Msg 1834, Level 16, State 1, Line 1
The file 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\01.Data\ContosoBKData.mdf' cannot be overwritten.  It is being used by database 'ContosoBK'.
Msg 3156, Level 16, State 4, Line 1
File 'ContosoBK_Data' cannot be restored to 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\01.Data\ContosoBKData.mdf'. Use WITH MOVE to identify a valid location for the file.
Msg 1834, Level 16, State 1, Line 1
The file 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\02.Log\ContosoBKLog.ldf' cannot be overwritten.  It is being used by database 'ContosoBK'.
Msg 3156, Level 16, State 4, Line 1
File 'ContosoBK_Log' cannot be restored to 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\02.Log\ContosoBKLog.ldf'. Use WITH MOVE to identify a valid location for the file.
Msg 3119, Level 16, State 1, Line 1
Problems were identified while planning for the RESTORE statement. Previous messages provide details.
Msg 3013, Level 16, State 1, Line 1
RESTORE DATABASE is terminating abnormally.
*/

-- https://www.mssqltips.com/sqlservertutorial/122/retore-sql-server-database-to-different-filenames-and-locations/

/* 
Theory:
-------

 RESTORE ... WITH MOVE 
	option allows you to restore database, but also specify the new location for the database 
	files (mdf and ldf)
	
 RESTORE ... WITH MOVE option will allow user to determine what to name the database files and 
	also what location these files will be created
	
 If WITH MOVE option is not used SQL Server will restore to the default location (at the time of 
	backup) will use the same name

 If another database already exists with the same name to what we are trying to restore and that
	database is already online then our restore will fail

 If database is no online for some reason and files are not open, then restore will overwrite 
	the files if WITH MOVE option is not used, so we should be very careful while using 
	RESTORE option
	
 Also when using WITH MOVE option we should make sure the account which we are using for 
	has SQL Server enginer has sufficient permission to create files / folder 
	
 So in RESTORE the first thing we need to know is the 
	(a) Logical Name and
	(b) Physical Location of the file
 RESTORE FILELISTONLY .. command will help with the details	
 
*/	

RESTORE FILELISTONLY FROM DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBK.bak';
GO

/*
OP:
---
LogicalName		PhysicalName							Type	FileGroupName		Size		MaxSize		FileId	CreateLSN	DropLSN		UniqueId								ReadOnlyLSN	ReadWriteLSN	BackupSizeInBytes	SourceBlockSize	FileGroupId	LogGroupGUID	DifferentialBaseLSN	DifferentialBaseGUID					IsReadOnly	IsPresent	TDEThumbprint
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ContosoBK_Data	D:\Users\..\01.Data\ContosoBKData.mdf	D		PRIMARY				15728640	52428800	1		0			0			825605CE-5CAF-4318-8EB9-3CCD190CED94	0			0				14876672			512				1			NULL			0					00000000-0000-0000-0000-000000000000	0			1			NULL
ContosoBK_Log	D:\Users\..\02.Log\ContosoBKLog.ldf		L		NULL				5242880		26214400	2		0			0			F470EA28-53C8-4257-BE51-1ACDD7A6DB41	0			0				0					512				0			NULL			0					00000000-0000-0000-0000-000000000000	0			1			NULL
*/

-- Restore full Backup WITH MOVE and CHECKSUM

RESTORE DATABASE ContosoBKWCSM
 FROM DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBK.bak'
 WITH MOVE 'ContosoBK_Data' TO 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\01.Data\ContosoBKWCSMData.mdf',
	  MOVE 'ContosoBK_Log' TO 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\02.Log\ContosoBKWCSMLog.ldf',
 CHECKSUM;
GO 

--OP:
-- Processed 1816 pages for database 'ContosoBKWCSM', file 'ContosoBK_Data' on file 1.
-- Processed 2 pages for database 'ContosoBKWCSM', file 'ContosoBK_Log' on file 1.
-- RESTORE DATABASE successfully processed 1818 pages in 0.773 seconds (18.367 MB/sec).

-- Restore full Backup WITH MOVE and NO_CHECKSUM (but the backup was taken with CHECKSUM enabled)

RESTORE DATABASE ContosoBKNCSM
 FROM DISK = 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\03.Backup\ContosoBK.bak'
 WITH MOVE 'ContosoBK_Data' TO 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\01.Data\ContosoBKNCSMData.mdf',
	  MOVE 'ContosoBK_Log' TO 'D:\Users\263642\Desktop\Working\80.TSQLServies\01.SQLDB\02.Log\ContosoBKNCSMLog.ldf',
 NO_CHECKSUM;
GO 

/*
OP:
---
Processed 1816 pages for database 'ContosoBKNCSM', file 'ContosoBK_Data' on file 1.
Processed 2 pages for database 'ContosoBKNCSM', file 'ContosoBK_Log' on file 1.
RESTORE DATABASE successfully processed 1818 pages in 0.672 seconds (21.127 MB/sec).
*/