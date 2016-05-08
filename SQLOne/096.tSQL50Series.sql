-- !!! Sri Krishnarpanam !!!
-- Source: http://www.c-sharpcorner.com/article/50-important-queries-in-sql-server/

--01. Retrieve all the databases in a SQL instance
use master;
GO

Exec sp_helpdb;
GO

/* Query Output:
name                                                                                                                             db_size       owner                                                                                                                            dbid   created     status                                                                                                                                                                                                                                                           compatibility_level
-------------------------------------------------------------------------------------------------------------------------------- ------------- -------------------------------------------------------------------------------------------------------------------------------- ------ ----------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -------------------
ASPState                                                                                                                               3.83 MB Vinayagar\Maruthi                                                                                                                18     Apr 25 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                           110
DEMODBMP01                                                                                                                             3.83 MB Vinayagar\Maruthi                                                                                                                9      Jan 27 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                           110
DEMODBMP05                                                                                                                             5.13 MB Vinayagar\Maruthi                                                                                                                14     Jan 27 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=French_CI_AI, SQLSortOrder=0, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                                            110
DEMODBMP11                                                                                                                             3.83 MB Vinayagar\Maruthi                                                                                                                16     Apr 19 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                           110
master                                                                                                                                 5.00 MB sa                                                                                                                               1      Apr  8 2003 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=SIMPLE, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics                                                            110
model                                                                                                                                  3.81 MB sa                                                                                                                               3      Apr  8 2003 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics                                                              110
msdb                                                                                                                                  36.31 MB sa                                                                                                                               4      Feb 10 2012 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=SIMPLE, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                         110
OMS                                                                                                                                    6.38 MB Vinayagar\Maruthi                                                                                                                7      Dec 31 2015 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                           100
ReportServer                                                                                                                          11.94 MB Vinayagar\Maruthi                                                                                                                5      Dec  7 2015 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=Latin1_General_CI_AS_KS_WS, SQLSortOrder=0, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                              110
ReportServerTempDB                                                                                                                     5.13 MB Vinayagar\Maruthi                                                                                                                6      Dec  7 2015 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=SIMPLE, Version=706, Collation=Latin1_General_CI_AS_KS_WS, SQLSortOrder=0, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                            110
Security                                                                                                                               3.83 MB Vinayagar\Maruthi                                                                                                                17     Apr 25 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=FULL, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics, IsFullTextEnabled                                           110
tempdb                                                                                                                                 8.50 MB sa                                                                                                                               2      May  7 2016 Status=ONLINE, Updateability=READ_WRITE, UserAccess=MULTI_USER, Recovery=SIMPLE, Version=706, Collation=SQL_Latin1_General_CP1_CI_AS, SQLSortOrder=52, IsAutoCreateStatistics, IsAutoUpdateStatistics                                                            110
*/

--02. Display text of a storedProcedure, View, Trigger

--Syntax: Exec sp_helptext @objname = 'Object_Name'
use Security;
GO

Exec sp_helptext @objname = '[CheckSchemaVersion]';
GO

/* Query Output:
Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].CheckSchemaVersion
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    IF (EXISTS( SELECT  *
                FROM    dbo.SchemaVersions
                WHERE   Feature = LOWER( @Feature ) AND
                        CompatibleSchemaVersion = @CompatibleSchemaVersion ))
        RETURN 0

    RETURN 1
END 
*/

--03. Get all the storedprocedures that are related to a database

--Source Table: syscomments, sysobjects

SELECT * FROM syscomments (NoLock);
SELECT * FROM sysobjects (NoLock);

SELECT DISTINCT syso.name, syso.xtype
FROM			syscomments sysc
 INNER JOIN		sysobjects syso
ON				sysc.id = syso.id
WHERE			syso.xtype = 'P';

/* Output:
name										xtype
-------------------------------------------------
AnyDataInTables								P 
Applications_CreateApplication				P 
CheckSchemaVersion							P 
Membership_ChangePasswordQuestionAndAnswer	P 
*/

-- To retrieve views use 'V' instead of 'P' and for functions use 'FN'

-- Display Views
SELECT DISTINCT syso.name, syso.xtype
FROM			syscomments sysc
 INNER JOIN		sysobjects syso
ON				sysc.id = syso.id
WHERE			syso.xtype = 'V';

/* Output:
name				xtype
-------------------------
vw_Applications		V 
vw_MembershipUsers	V 
vw_Profiles			V 
*/

--Display Functions

SELECT DISTINCT syso.name, syso.xtype
FROM			syscomments sysc
 INNER JOIN		sysobjects syso
ON				sysc.id = syso.id
WHERE			syso.xtype = 'FN';

/* Output:
name				xtype
-------------------------
*/

--04. Get all the StoredProcedures that are related to a table

SELECT id, text FROM syscomments sysc (NoLock);
SELECT id, name, xtype FROM sysobjects syso (NoLock);

--table to identify: [spt_fallback_usg]

SELECT			syso.name, syso.xtype
FROM			syscomments sysc
 INNER JOIN		sysobjects syso
ON				sysc.id = syso.id
WHERE			sysc.text = '%spt_fallback_usg%'
 AND			syso.xtype = 'P';

sp_helptext 'sp_addapprole'