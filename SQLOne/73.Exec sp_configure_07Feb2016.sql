--							||| Krishna Ya Samarpanam |||
--Description	: Exec sp_configure [parameter]

USE master;
Go

EXEC sp_configure 'show advanced options'
GO

--OP:
--name						| minimum |	maximum	| config_value	| run_value
--show	advanced options	| 0		  | 1		| 0				| 0

--Link: https://msdn.microsoft.com/en-in/library/ms188787.aspx

--sp_configure: Display or change Global Configuration setting for the current server (Change Server Level settings)
--When execuited with out any parameters [sp_configure] returns a result with 05 columns (as above)
--The values of the last 02 columns [config_value] and [run_value] are not automatically equivalent
--after running 'sp_configure' the System Administrator must run the command [RECONFIGURE] or [RECONFIGURE WITH OVERRIDE]
--Column Descriptions:
--	Name		: Name of the configuration option
--	minimum		: Minimum value of the configuration option
--  maximum		: Maximum value of the configuration option
--  config_value: Value to which the configuration option was set [sys.configurations.value]
--  run_value	: Currently running value of the configuration option [sys.configurations.value_in_use]

--Output: Return value [0 - Success] and [1 - Failure]

--To make changes at server level: [sp_configure]
--To make changes at database level: [ALTER database]
--To make changes at user level: [SET statements]

--01. When a new value is set in the result set shows the value 'config_value' 
--02. This value differs from value in column 'run_value' (which is the currently running configuration value)
--03. To update the value in column 'run_value' the system adminitrator must run either [RECONFIGURE] or [RECONFIGURE WITH OVERRIDE]
--04. The basic RECONFIGURE statement reject any value that is outside the reasonable range
--05. RECONFIGURE WITH OVERRIDE in contrast accepts any value with correct DataType and forces reconfiguration with specified values
--06. Always use [RECONFIGURE WITH OVERRIDE] option cautiously as inappropriate value will have adverse effect in the instance
--07. For a dynamically updated value the  run_value and config_value columns should match and no need to restart the server
--08. All the information will be available in the catalog 'sys.configurations'
--09. The below SELECT and Exec are the same commands
--10. If the specified value is too high for an option the 'run_value' column reflects that the datbase engine has defaulted to 
--	dynamic value rather than setting a invalid value

--Advanced Configuration Options:
---------------------------------
--11. Few configuration options are designed as advanced options, these options are not avaiable for viewing and changing
--		E.g affinity mask and recovery interval
--12. To view the values available, set 'Show Advanced Options' configuration option to 1

--Listing advanced configuration Option
---------------------------------------

USE master;
GO
Exec sp_configure 'show advanced option', '1';

--OP: Configuration option 'show advanced options' changed from 0 to 1. Run the RECONFIGURE statement to install.

--Now run RECONFIGURE to show all configuration options

RECONFIGURE;
Exec sp_configure;

--Now 67 rows are displayed as output

--Reset it back to default value to display only 17 rows

USE master;
GO

Exec sp_configure 'show advanced option', '0';
GO
--OP: Configuration option 'show advanced options' changed from 1 to 0. Run the RECONFIGURE statement to install.

RECONFIGURE;
Exec sp_configure;
GO 
--OP: Now 17 rows are displayed as output

--Link: https://msdn.microsoft.com/en-us/library/ms188265.aspx
--13. 'show advanced option', '0' is the default value
--14. The change takes place immediately with out a server restart

--Both the below statements are same
SELECT * FROM sys.configurations WHERE is_advanced = 0
Exec sp_configure