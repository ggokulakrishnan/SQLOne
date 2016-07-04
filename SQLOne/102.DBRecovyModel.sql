--Source: https://sqlandme.com/2014/01/06/sql-server-different-ways-to-check-recovery-model-of-a-database/

--SQL Server – Different ways to check Recovery Model of a database

/*
Recovery model is a propety in a database used to know how transaction log is maintained in a database
SQL Server supports 03 types of recovery model:
	- SIMPLE
	- FULL
	- BULK-LOGGED recovery models

Using SSMS: Right click on Database in Object Explorer > go to Properties dialog box > Options page > Recovery model
*/

--A. Using Metadata functions: DATABASEPROPERTYEX()

SELECT [RecoveryModel] = DATABASEPROPERTYEX('ContosoBK', 'Recovery');
GO

/* OP:
RecoveryModel
-------------
FULL
*/

--B. Using Catalog View

SELECT [DatabaseName] = name
	   , [RecoveryModel] = recovery_model_desc
FROM   sys.databases (NoLock)
WHERE  name = 'ContosoBK';
GO