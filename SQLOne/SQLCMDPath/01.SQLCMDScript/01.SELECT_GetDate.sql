SELECT GETDATE();

SET NOCOUNT ON;
SELECT	SERVERPROPERTY('ServerName') AS ServerName
        , SERVERPROPERTY('ProductVersion') AS ProductVersion
        , SERVERPROPERTY('ProductLevel') AS ProductLevel
        , SERVERPROPERTY('Edition') AS Edition
        , SERVERPROPERTY('EngineEdition') AS EngineEdition;
GO