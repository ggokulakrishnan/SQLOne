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