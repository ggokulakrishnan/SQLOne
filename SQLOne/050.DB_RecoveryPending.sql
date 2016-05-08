-- Topic: Database in 'recovery pending' Eg) AdventureWorks2012 (Recovery Pending)
-- Description: Use trial and error and get down to the solution
-- Source: https://www.xtivia.com/recovering-recovery-pending-status/
-- Date: 08-May-2016

--Recovering from 'recovery pending' status
--01. Seeing a database in any state other than "online" makes me a little nervous
--02. For one thing, it’s one of those things I don’t see often, so I have to rub a few brain cells 
--		together to remember what I did the last time. For another, there’s no guarantee that you’ll 
--		be able to get the database back online. That’s scary.

--Error (01):
--"Error: 5173, Severity: 16, State: 1. One or more files do not match the 
--	primary file of the database. If you are attempting to attach a database, 
--	retry the operation with the correct files. If this is an existing database,
--	the file may be corrupted and should be restored from backup."

--Error (02):
--"Error: 928, Severity: 20, State: 1: During upgrade, database raised exception 
--	945, severity 14, state 2, address (). Use the exception number to determine 
--	the cause."

--The 928 error was a typical Microsoft red herring having to do with database 
--	compatibility levels and permissions. However, trying to bring the database online added a little 
--	meat to the 5173 error’s bones:

--Error (03):
--"Database [dbname] cannot be opened due to inaccessible files or insufficient 
--	memory or disk space. See the SQL Server errorlog for details."

--Error (04):
--"Log file [log name] does not match the primary file. It may be from 
--	a different database or the log may have been rebuilt previously."

--I checked file permissions, memory and disk space. Everthing was kosher there. I knew 
--	that would be the case because life just isn’t that easy.

--Which left the log files. These databases (along with a dozen others in the instance) had 
--	been involved in a SAN crash. They were migrated to a new disk, but performance was awful - data 
--	warehouse processes were taking 10 times longer to run than they had previously. So the client 
--	built a new drive for the logs, migrated the logs, changed the drive letter, and altered the file 
--	paths stored in the master database. Plenty of opportunities there to corrupt the log.

--I had no backups to work with, so I needed to recover the databases. I put one of the db’s in 
--	emergency mode to try to run CHECKDB, but CHECKDB couldn’t access the files either.

--So, on to the last resort (I’ll spare you the trial and error and get down to the solution):

--01. Set the database status to emergency:
ALTER DATABASE AdventureWorks2012 SET EMERGENCY;
--OP: Command(s) completed successfully.

--02. Put the database in multi-user mode:
ALTER DATABASE AdventureWorks2012 SET MULTI_USER;
--OP: Command(s) completed successfully.

--03. Detach the database:
EXEC sp_detach_db 'AdventureWorks2012';

--04. Reattach the data file only:
EXEC sp_attach_single_file_db @dbname = 'AdventureWorks2012', 
     @physname = N'D:\Projects\Developer Series\developer.sqlOne\DataFilesSQL2012\Data\AdventureWorks2012_Data.mdf';

--OP: Command(s) completed successfully.

--Understandings:
-----------------
--(A) The point here is to get rid of the corrupt log and let SQL Server build a new one. Three words to the wise:

--(B) First, according to Microsoft, you should use sp_attach_single_file_db ONLY on data files detached using 
--		sp_detach_db. So don’t use the GUI - use sp_detach_db

--(C) Second, put the database in MULTI_USER mode before detaching. SQL Server can’t build a new log if the data 
--		file is read-only. If you detach in SINGLE_USER mode, Plan B is a real pain.

--(D) Third, don’t make your DBA do this. Back up your databases

-- ** No Success with the above methods: **

USE [master];
GO

--OP:
--Msg 233, Level 20, State 0, Line 0
--A transport-level error has occurred when sending the request to the server. (provider: Shared Memory Provider, error: 0 - No process is on the other end of the pipe.)
--RCA(Solution): Unable to connect to SQL database engine

-- Set database to single user mode
ALTER DATABASE AdventureWorks2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
--OP: Command(s) completed successfully.

ALTER DATABASE AdventureWorks2012 SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO

--OP: Command(s) completed successfully.
--Database moves to Offline mode ie.) AdventureWorks2012 (Offline)

---- Detach the database
--sp_detach_db 'AdventureWorks2012'
--GO
----OP: Command(s) completed successfully.


USE master; --do this all from the master
GO

ALTER DATABASE AdventureWorks2012
MODIFY FILE (name		= 'AdventureWorks2012'
             , filename	= 'D:\Projects\Developer Series\developer.sqlOne\DataFilesSQL2012\Data\AdventureWorks2012_Data.mdf');
			 --filename is new location of .mdf file
			 
ALTER DATABASE AdventureWorks2012
MODIFY FILE (name		= 'AdventureWorks2012_Log'
             , filename	= 'D:\Projects\Developer Series\developer.sqlOne\DataFilesSQL2012\Data\AdventureWorks2012_Log.ldf');
			 --filename is new location of .ldf file
GO

--OP: (If name is not matching [name = 'AdventureWorks2012_Data'] to the original database the below error will appear)
--Msg 5041, Level 16, State 2, Line 2
--MODIFY FILE failed. File 'AdventureWorks2012_Data' does not exist.
--The file "AdventureWorks2012_Log" has been modified in the system catalog. The new path will be used the next time the database is started.

--Update [name = 'AdventureWorks2012_Data'] to [name = 'AdventureWorks2012'] and rerun it again

--OP: 
--The file "AdventureWorks2012" has been modified in the system catalog. The new path will be used the next time the database is started.
--The file "AdventureWorks2012_Log" has been modified in the system catalog. The new path will be used the next time the database is started.


-- Alternate Example to attach mdf / ldf file
USE master
GO
	-- Now Attach the database
	Exec sp_attach_DB 'AdventureWorks2012',
		'D:\Projects\Developer Series\developer.sqlOne\DataFilesSQL2012\Data\AdventureWorks_Data.mdf',
		'D:\Projects\Developer Series\developer.sqlOne\DataFilesSQL2012\Data\AdventureWorks_Log.ldf';
	GO

ALTER DATABASE AdventureWorks2012 SET ONLINE;
GO

--OP:
--Msg 5120, Level 16, State 101, Line 1
--Unable to open the physical file "D:\Projects\Developer Series\developer.sqlOne\ADWorks2012OLTPDB\Data\AdventureWorks2012_Data.mdf". Operating system error 5: "5(Access is denied.)".
--Msg 5120, Level 16, State 101, Line 1
--Unable to open the physical file "D:\Projects\Developer Series\developer.sqlOne\ADWorks2012OLTPDB\Data\AdventureWorks2012_Log.ldf". Operating system error 5: "5(Access is denied.)".
--Msg 5181, Level 16, State 5, Line 1
--Could not restart database "AdventureWorks2012". Reverting to the previous status.
--Msg 5069, Level 16, State 1, Line 1
--ALTER DATABASE statement failed.

ALTER DATABASE AdventureWorks2012 SET MULTI_USER;
GO


USE master
GO

-- Now Attach the database
sp_attach_DB 'AdventureWorks2012',
'D:\Program Files\Microsoft SQL Server\MSSQL\Data\AdventureWorks_Data.mdf',
'E:\Move LogFile here through T-SQL\AdventureWorks_Log.ldf'
GO

