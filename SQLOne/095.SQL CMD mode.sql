:SETVAR ScriptPath "D:\Projects\DemoSQL\SQLGit\SQLOne\SQLOne\SQLCMDPath\01.SQLCMDScript\"
:SETVAR ScriptFileName "01.SELECT_GetDate.sql"
:r $(ScriptPath)$(ScriptFileName)

:SETVAR Path "D:\Projects\DemoSQL\SQLGit\SQLOne\SQLOne\SQLCMDPath\03.SQLCMDResult\"
:SETVAR FileName "QueryResults.txt"
:OUT $(Path)$(FileName)

:SETVAR ErrPath "D:\Projects\DemoSQL\SQLGit\SQLOne\SQLOne\SQLCMDPath\02.SQLCMDError\"
:SETVAR ErrFileName "ErrorLog.log"
:ERROR $(ErrPath)$(ErrFileName)

:ON ERROR EXIT
:CONNECT (local)

--:CONNECT (local) = --:CONNECT (VINAYAGAR)
-------------------------------------------------------------------------------
--:CONNECT (local)		-- (local) (SQL Server 11.0.3156 - VINAYAGAR\Maruthi)
--:CONNECT (VINAYAGAR)	-- VINAYAGAR (SQL Server 11.0.3156 - VINAYAGAR\Maruthi)

SET NOCOUNT ON;
SELECT	SERVERPROPERTY('ServerName') AS ServerName
        , SERVERPROPERTY('ProductVersion') AS ProductVersion
        , SERVERPROPERTY('ProductLevel') AS ProductLevel
        , SERVERPROPERTY('Edition') AS Edition
        , SERVERPROPERTY('EngineEdition') AS EngineEdition;
GO

:CONNECT SQL2
SET NOCOUNT ON;
SELECT	SERVERPROPERTY('ServerName') AS ServerName
        , SERVERPROPERTY('ProductVersion') AS ProductVersion
        , SERVERPROPERTY('ProductLevel') AS ProductLevel
        , SERVERPROPERTY('Edition') AS Edition
        , SERVERPROPERTY('EngineEdition') AS EngineEdition
GO


--Example #02:

:ON ERROR EXIT
 
:SETVAR Path "D:\Projects\DemoSQL\SQLGit\SQLOne\SQLOne\SQLCMDPath\01.SQLCMDScript\"
:SETVAR ScriptToExecute "02.Revoke_Guest_Access_From_Database.sql"
:SETVAR ErrPath "D:\Projects\DemoSQL\SQLGit\SQLOne\SQLOne\SQLCMDPath\02.SQLCMDError\"
:SETVAR ErrFileName "ErrorLog.log"
:ERROR $(ErrPath)$(ErrFileName)
USE DEMODBMP01
:R $(Path)$(ScriptToExecute)
USE DEMODBMP01
:R $(Path)$(ScriptToExecute)

--Example #03:
--Execuiting System Commands

EXEC master.dbo.xp_cmdshell systeminfo
GO
!!systeminfo
