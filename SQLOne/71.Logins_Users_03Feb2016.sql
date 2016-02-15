--										Sri Rama Jaya Rama Jaya Jaya Rama

--01. Creating a new SQL Login


--Understandings:
--Links: https://technet.microsoft.com/en-us/library/aa337562(v=sql.110).aspx
--01. A login is the identity of the person or process that is connecting to an instance of SQL Server
--02. Login is a security principle (which can be authenticted by security system)
--03. Users needs to have a login to connect to a SQL Instance
--04. Login can be created on Windows principle (Domain User / Windows Domain Group)
--05. A Login which is created not based on Windows principle is (SQL Server Login), to use this login type SQL server 
--		must be configured in mixed mode authentication

--06. Login Scope: With security principle, permission is granted to the logins. The scope of the login is to the whole database
--07. To connect a database on an instance of SQL Server the [LOGIN] must be mapped to a database [USER]
--08. Permission inside the database are granted based on database [USER] and NOT the [LOGIN]

--09. Creating a [LOGIN] with Windows Authetication:
--10. Open cmd (Command Prompt) with Run As 'Administrator' and enter the command C:\>net user (enter)
--OP: 
/* 
C:\>net user
User accounts for \\VINAYAGAR
-------------------------------------------------------------------------------
Administrator            Guest                    Maruthi
The command completed successfully.
*/
--11. Here we have 03 logins created in windows, we will use the account [Maruthi] for our demo and 
--	create a login with this name in SQL Server
--12. Create a [LOGIN] for SQL Server by specifying server name and windows domain account name
--13. Here Server Name: (Maruthi) and Windows Domain Account Name: (Vinayagar)

CREATE LOGIN [<domainName>\<loginName>] FROM WINDOWS;
GO

CREATE LOGIN [VINAYAGAR\Maruthi] FROM WINDOWS;
GO

--https://technet.microsoft.com/en-us/library/ms189751(v=sql.110).aspx
--https://technet.microsoft.com/en-us/library/aa337562(v=sql.110).aspx
--http://www.c-sharpcorner.com/UploadFile/dhananjaycoder/create-a-sql-login-user-in-sql-server-2008/
--http://debugmode.net/

--http://superuser.com/questions/344728/list-members-of-a-windows-group-using-command-line
--C:\>WMIC
--wmic:root\cli>/?
--wmic:root\cli>USERACCOUNT