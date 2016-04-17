-- Script to list out SQL Logins and Database User Mappings

--Source: https://sqldbpool.com/2015/02/03/script-to-list-out-sql-logins-and-database-user-mappings/

-- Use system stored procedure sp_msloginmappings to list out the SQL logins and database user mappings

-- Parameters:
-- @Loginname – Optional argument, in case if you not specify the Login name procedure will return 
--	the result for all the SQL Server logins

-- @Flags – You can specify value 0 or 1, 0 value will show user mapping to all databases and 1 will 
--	show the user mapping to current database only. Default value is 0

use master
go
exec sp_msloginmappings 'sa', 0

use master
go
exec sp_msloginmappings 'sa', 1

use master
go
exec sp_msloginmappings null, 0

-- In case you want to run the sp_msloginmappings across multiple SQL Instance 

create table #loginmappings(  
 LoginName  nvarchar(128) NULL,  
 DBName     nvarchar(128) NULL,  
 UserName   nvarchar(128) NULL,  
 AliasName  nvarchar(128) NULL 
)  
 
insert into #loginmappings
EXEC master..sp_msloginmappings
 
select * from #loginmappings order by LoginName asc
 
drop table #loginmappings