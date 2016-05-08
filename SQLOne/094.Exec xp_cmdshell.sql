--Sri Krishnarpanam

--Topic: Enabling & Disabling xp_cmdshell in SQL SERVER
--Source: http://www.c-sharpcorner.com/blogs/enabling-disabling-xpcmdshell-in-sql-server1

-- (a) To allow advanced options to be changed. 

EXEC sp_configure 'show advanced options', 1 
GO 
--OP: Configuration option 'show advanced options' changed from 0 to 1. Run the RECONFIGURE statement to install.

-- (b) To update the currently configured value for advanced options. 
RECONFIGURE 
GO
--OP: Msg 5593, Level 16, State 1, Line 1
--		FILESTREAM feature is not supported on WoW64. The feature is disabled. 

SELECT * FROM SYS.CONFIGURATIONS WHERE Name = 'show advanced options'

--configuration_id name                   value   minimum    maximum   value_in_use    description              is_dynamic is_advanced
------------------ ---------------------- ------- ---------- --------- --------------- ------------------------ ---------- -----------
--518              show advanced options  1       0          1         0               show advanced options    1          0

-- (c) Disabling xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0
GO
RECONFIGURE
GO
/* OP:
Msg 15123, Level 16, State 1, Procedure sp_configure, Line 62
The configuration option 'xp_cmdshell' does not exist, or it may be an advanced option.
Msg 5593, Level 16, State 1, Line 1
FILESTREAM feature is not supported on WoW64. The feature is disabled. */

-- (d) Check the Disabled record

SELECT	* 
FROM	SYS.CONFIGURATIONS 
WHERE	Name = 'xp_cmdshell'

--OP:
--configuration_id name          value   minimum   maximum   value_in_use   description                      is_dynamic is_advanced
------------------ ------------- ------- --------- --------- -------------- -------------------------------- ---------- -----------
--16390            xp_cmdshell   0       0         1         0              Enable or disable command shell  1          1


-- (e) Enabling xp_cmdshell

EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

/* OP: 
Msg 15123, Level 16, State 1, Procedure sp_configure, Line 62
The configuration option 'xp_cmdshell' does not exist, or it may be an advanced option.
Msg 5593, Level 16, State 1, Line 1
FILESTREAM feature is not supported on WoW64. The feature is disabled. */

-- (f) Check the Enabled record.

SELECT	* 
FROM	SYS.CONFIGURATIONS 
WHERE	Name = 'xp_cmdshell';
GO

--OP:
--configuration_id name          value   minimum   maximum   value_in_use   description                      is_dynamic is_advanced
------------------ ------------- ------- --------- --------- -------------- -------------------------------- ---------- -----------
--16390            xp_cmdshell   0       0         1         0              Enable or disable command shell  1          1

-- (g) Example

-- (1) EXECUTE [master].[dbo].[xp_cmdshell] 'sqlcmd -Lc'
-- (2) EXECUTE [master].[dbo].[xp_cmdshell] 'sqlcmd whoami /user'