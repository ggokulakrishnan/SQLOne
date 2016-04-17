--Sri Krishnarpanam

--Topic: Understanding SQL Logins
--Link: https://www.mssqltips.com/sqlservertip/2038/understanding-how-a-user-gets-database-access-in-sql-server/

--We Create a Login (lgnSara) 

CREATE	LOGIN [lgnSara] WITH PASSWORD=N'hello'
		MUST_CHANGE, 
		CHECK_EXPIRATION=ON, 
		CHECK_POLICY=ON,
		DEFAULT_DATABASE=[master], 
		DEFAULT_LANGUAGE=[English];

/* Enumerating Logins */
SELECT		* 
FROM		sys.server_principals
ORDER BY	type, [name];

--type
-- (a) R: Specifies that the data is for a SERVER_ROLE (SQL Server Role) [E.g. bulkadmin, dbcreator, diskadmin, processadmin, 
--				public, securityadmin, serveradmin, setupadmin, sysadmin)
-- (b) U: Login of the type WINDOWS_LOGIN (Windows domain account -based login) [E.g. NT AUTHORITY\SYSTEM, NT Service\MSSQLSERVER]
-- (c) G: This login is of type WINDOWS_GROUP (Windows domain group)
-- (d) S: SQL_LOGIN (SQL Server Specific User)
-- (e) C: CERTIFICATE_MAPPED_LOGIN (login mapped to a certificate)
-- (f) K: ASYMMETRIC_KEY_MAPPED_LOGIN (login mapped to an asymmetric key)

-- It is worth mentioning that the column is_disabled specifies whether 
--	the account is disabled (which equals 1) or enabled (which equals 0)

-- Worth mentioning too that the column sid specifies the SID (Security Identifier) of the login. If this 
--	is a Windows principal (user or group,) it matches Windows SID. Otherwise, it stores the SID created 
--	by SQL Server to that login (or role.)

SELECT		name
			, principal_id
			, sid
			, type
			, type_desc
			, is_disabled -- (0 Disabled, 1 Enabled)
			, default_database_name
FROM		sys.server_principals
WHERE		type = 'S' AND
			name = 'lgnSara';

--OP:
--name		principal_id	sid									type		type_desc	is_disabled		default_database_name
-----------------------------------------------------------------------------------------------------------------------------
--lgnSara	274				0xF8121EE109ADAF4EA3275AB9DD65AFFF	S			SQL_LOGIN	0				master



--About Logins: 
---------------
-- 01. In an instance, all logins can access the master database (all logins can access the master database)
-- 02. With the below 05 possible ways a login can connect to a database
--			(a) Explict access is granted to a login
--			(b) Login is a member of sysadmin (fixed server role)
--			(c) Login has CONTROL SERVER permission (in 2005 and 2008 only)
--			(d) Login is the owner of the database
--			(e) GUEST user is enabled in the database

--02.a Explicit Access (Login is mapped to a Database User)
--	In SQL Server 2005 and 2008 there are new T-SQL commands to create logins and users. So we would use the 
--	following commands:

CREATE USER usrSara FOR LOGIN lgnSara;
GO 
--OP: Command(s) completed successfully

--Note: Use of GO command, till the GO command is give all the tsql statements are stored in the buffer

--02.a.1 Validation of login and user status
 --	Login granted access in this manner should appear in the sysusers table (SQL Server 2000) or the 
 --	sys.database_principals catalog view (SQL Server 2005/2008) 

 -- Hierarchy: LOGIN --> USER --> ROLE

SELECT * FROM master..syslogins;

SELECT * FROM sysusers; 

-- SQL Server 2000 (mode) but still works with SQL Server 2008 and later
SELECT		sl.name AS 'Login', su.name AS 'User'
FROM		master..syslogins sl
	JOIN	sysusers su
ON			sl.sid = su.sid
ORDER BY	sl.name, su.name;

--OP: 
/*Login								User
------------------------------------------------------------------------
##MS_AgentSigningCertificate##		##MS_AgentSigningCertificate##
##MS_PolicyEventProcessingLogin##	##MS_PolicyEventProcessingLogin##
lgnSara								usrSara
NT SERVICE\ReportServer				NT SERVICE\ReportServer
sa									dbo  */

-- SQL Server 2005/2008 it is identified using sys.database_principles (DP) and sys.server_principles (SP)

SELECT * FROM sys.database_principals dp (NoLock);
SELECT * FROM sys.server_principals dp (NoLock);

SELECT		sp.name AS 'Login', dp.name AS 'User'
FROM		sys.database_principals dp
  JOIN		sys.server_principals sp
ON			dp.sid = sp.sid
ORDER BY	sp.name, dp.name;

--OP: 
/* Login							User
---------------------------------------------------------------------
##MS_AgentSigningCertificate##		##MS_AgentSigningCertificate##
##MS_PolicyEventProcessingLogin##	##MS_PolicyEventProcessingLogin##
lgnSara								usrSara
NT SERVICE\ReportServer				NT SERVICE\ReportServer
sa									dbo */

-- If we see a login match up to a user in this manner, then the login has access to the database

--03. Implicit Access (Member of Sysadmin Fixed Server Role):

-- (a) All members of the sysadmin fixed server role map to the dbo user of every database
-- (b) If a login is a member of sysadmin fixed server role, it automatically has access to every database.

-- (SQL Server 2000) See members of the sysadmin fixed server role:
EXEC sp_helpsrvrolemember 'sysadmin' 

--OP:
/* ServerRole	MemberName					MemberSID
----------------------------------------------------------------------------------------------------------------
sysadmin		sa							0x01
sysadmin		Vinayagar\Maruthi			0x0105000000000005150000007FC0B41011F5B931957D3535E8030000
sysadmin		NT SERVICE\SQLWriter		0x010600000000000550000000732B9753646EF90356745CB675C3AA6CD6B4D28B
sysadmin		NT SERVICE\Winmgmt			0x0106000000000005500000005A048DDFF9C7430AB450D4E7477A2172AB4170F4
sysadmin		NT Service\MSSQLSERVER		0x010600000000000550000000E20F4FE7B15874E48E19026478C2DC9AC307B83E
sysadmin		NT SERVICE\SQLSERVERAGENT	0x010600000000000550000000DCA88F14B79FD47A992A3D8943F829A726066357 */

-- (SQL Server 2005/2008) see members of the sysadmin fixed server role:
SELECT * FROM sys.server_principals (NoLock);	-- name (sysadmin, sa, pubic, etc..), principle_id
SELECT * FROM sys.server_role_members (NoLock); -- role_principle_id, member_principle_id

SELECT		sp.name, sp.type_desc, srm.role_principal_id
FROM		sys.server_role_members srm
 INNER JOIN	sys.server_principals sp
ON			srm.member_principal_id = sp.principal_id
WHERE		srm.role_principal_id = (
     SELECT principal_id
     FROM	sys.server_principals
     WHERE	[Name] = 'sysadmin'); --(3: sysadmin)

--04. Implicit Access (CONTROL SERVER permission - SQL Server 2005/2008):

-- (a) The CONTROL SERVER permission gives equivalent rights as a member of the sysadmin role with a few exceptions 
--		(which aren't of importance here)
-- (b) If a login doesn't map explicitly to a user in a database, but that login has CONTROL SERVER permissions, 
--		that login can still access the database
-- (c) Who has CONTROL SERVER permissions by the following query

SELECT * FROM sys.server_principals (NoLock);
SELECT * FROM sys.server_permissions (NoLock);

SELECT	sp.name 'Login' 
FROM	sys.server_principals sp
 JOIN	sys.server_permissions perms
ON		sp.principal_id = perms.grantee_principal_id
WHERE	perms.type = 'CL'	--(CL: CONTROL SERVER)
 AND	perms.state = 'G';  --(G: GRANT)

--05. Implicit Access (Database Owner):

-- (a) The database owner automatically maps into the database as the dbo user
-- (b) Query the sysdatabases table (SQL Server 2000) or sys.databases catalog view (SQL Server 2005/2008)

-- SQL Server 2000 (Lists all the database and their DB owners)

SELECT * FROM sysdatabases (NoLock);
SELECT * FROM syslogins (NoLock);

SELECT		db.name AS 'Database', sl.name AS 'Owner' 
FROM		sysdatabases db
 INNER JOIN syslogins sl
ON			db.sid = sl.sid
ORDER BY	db.name;

-- SQL Server 2005/08
SELECT * FROM sys.databases (NoLock);
SELECT * FROM sys.server_principals (NoLock);

SELECT		db.name AS 'Database', sp.name AS 'Owner'
FROM		sys.databases db 
 LEFT JOIN	sys.server_principals sp
ON			db.owner_sid = sp.sid
ORDER BY	db.name; 
 
--06. Implicit Access (Guest User Is Enabled):

-- A. A login can get access to a database is if the guest user is enabled for that database
-- B. If a login cannot map in any other way (users, role etc..) , it'll use guest if that's available
-- C. That's how logins can access the master database (in master guest is always enabled)
-- D. With respect to user databases, the guest user should only be enabled in special cases
-- E. For a user database the guest user is disabled by default
-- F. For two system databases the guest user must always remain enabled. 
--		(a) master
--	    (b) tempdb
-- G. This explains why logins always have access to master, even when explicit rights aren't visible
-- H. To see if the guest user is enabled we can query sysusers (SQL Server 2000) or 
--													   sys.database_permissions (SQL Server 2005/2008)

-- SQL Server 2000
SELECT * FROM sysusers (NoLock);

-- For the connected Database Check if guest is enabled or not
SELECT	su.name, CASE su.hasdbaccess WHEN 1 THEN 'Yes' ELSE 'No' END AS 'Enabled'
FROM	sysusers su
WHERE	su.name = 'guest'; 

-- SQL Server 2005/2008
-- In SQL Server 2005/2008 we have to look for the existence of the CONNECT permission at the database level 
-- If it exists, the guest user is enabled. If it doesn't, then the guest user is not.

SELECT * FROM sys.database_principals (NoLock);
SELECT * FROM sys.database_permissions (NoLock);

SELECT	dp.name, CASE perms.class WHEN 0 THEN 'Yes' ELSE 'No' END AS 'Enabled'
FROM	sys.database_principals dp
 LEFT JOIN (SELECT grantee_principal_id, class 
			FROM sys.database_permissions 
            WHERE class = 0 
			 AND type = 'CO' AND state = 'G') AS perms
ON		dp.principal_id = perms.grantee_principal_id
WHERE	dp.name = 'guest'; 