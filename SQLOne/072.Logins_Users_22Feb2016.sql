--Link: http://blogs.msdn.com/b/lcris/archive/2006/10/24/sql-server-2005-demo-for-enabling-database-impersonation-for-cross-database-access.aspx

/* This is a template */

-- A demo for cross database access
-- 
-- create our principals: alice, bob, charles
--

create login alice with password = 'SimplePwd01'
create login bob with password = 'SimplePwd01'
create login charles with password = 'SimplePwd01'

-- create two databases owned by alice and bob
--

create database db_alice
create database db_bob

alter authorization on database::db_alice to alice
alter authorization on database::db_bob to bob

--###################
--#Setting up db_bob#
--###################

use db_bob

-- execute the following as bob, this database's dbo
--
execute as login = 'bob'

-- add charles to bob's database
--
create user charles

-- create a table and a procedure accessing it,
-- both owned by charles
--

create table t (c int)
insert into t values (42)

alter authorization on t to charles

create procedure proc_select_t as
begin
    select * from sys.login_token
    select db_name()
    select * from sys.user_token
 
    print 'Selecting from t...'
    select * from t
end

alter authorization on proc_select_t to charles

create procedure proc_drop_t as begin
    select * from sys.login_token
    select db_name()
    select * from sys.user_token
	print 'Dropping t...'
    drop table t
end

alter authorization on proc_drop_t to charles

-- verify the selection procedure
--

execute as user = 'charles'

exec proc_select_t

-- revert impersonation of charles
--

revert 
-- revert impersonation of bob
--

revert

--#####################
--#Setting up db_alice#
--#####################

use db_alice

-- execute the following as alice, this database's dbo
--
 
execute as login = 'alice'

-- add charles to alice's database
--
 
create user charles

-- note that alice cannot impersonate charles at server level
-- the following call will produce an ERROR!
--
 
execute as login = 'charles'

-- however, being the dbo, she can impersonate charles at database level
--
 
execute as user = 'charles' 

select * from sys.login_token
select * from sys.user_token

revert

-- create a procedure for cross database access
--

go

create procedure proc_crossdb
  with execute as 'charles'
as
begin
    select * from sys.login_token
    select db_name()
    select * from sys.user_token
	exec db_bob.dbo.proc_select_t
end

go

-- call the procedure, to impersonate charles and access bob's database
--
 
exec dbo.proc_crossdb
--
-- won't work - database is not trustworthy
-- user token is "sandboxed"

-- revert the impersonation of alice
--
revert 

--####################################
--#Setting up db_alice as trustworthy#
--####################################

-- let's mark alice's database as trustworthy
--
 
alter database db_alice set trustworthy on

--###################################
--#Checking proc_crossdb in db_alice#
--###################################

-- now let's see if this changes anything
--
 
execute as login = 'alice'

exec dbo.proc_crossdb

--
-- we now see alice as an authenticator,
-- but bob doesn't trust alice to authenticate,
-- so it still doesn't work

revert

--#######################################################
--#Setting up alice as trusted to authenticate in db_bob#
--#######################################################

-- let's make bob trust alice to authenticate
--
 
use db_bob

execute as login = 'bob'

create user alice

grant authenticate to alice 

revert

--###################################
--#Checking proc_crossdb in db_alice#
--###################################

-- let's see how things work now
--

use db_alice

execute as login = 'alice'

exec dbo.proc_crossdb

--
-- the token authenticated by alice is now accepted

revert

--##########
--#Comments#
--##########

-- unfortunately, this method would also allow alice
-- to rewrite the proc_crossdb procedure and call proc_drop_t instead
--
-- what do we do if we don't trust alice, but we'd like to enable the select scenario?
--
-- signing allows better control because it requires trusting code not principals

--##################################################
--#Cleaning up db_bob and setting it up for signing#
--##################################################

-- first, let's remove the trustworthy setting on alice's database
-- and bob's trust in alice as an authenticator
--

alter database db_alice set trustworthy off

use db_bob

execute as login = 'bob'

-- remove alice, which will drop any permissions as well
--

drop user alice

-- now we'll use signing to enable cross database access
-- we'll create a certificate and a principal mapped to it
-- that will be used as authenticator
--
 
create certificate cert_sign_alice
  encryption by password = 'SimplePwd01'
  with subject = 'Sign procedures in Alice''s database'

create user u_cert_sign_alice from certificate cert_sign_alice

grant authenticate to u_cert_sign_alice

-- we create and sign the proc_crossdb procedure in bob's database,
-- because we don't want to give the private key of the certificate to alice
--
go

create procedure proc_crossdb 
  with execute as 'charles'
as
begin
    select * from sys.login_token
    select db_name()
    select * from sys.user_token

    exec db_bob.dbo.proc_select_t
end
go

add signature to proc_crossdb by certificate cert_sign_alice with password = 'SimplePwd01'

-- retrieve the signature from the catalogs
--
 
select crypt_property from sys.crypt_properties where major_id = object_id('proc_crossdb')

--
-- the value returned will change because the certificate will be generated randomly
-- we need to copy the returned value
-- for my execution, I got back:
-- 0x17B803D0550C450AD4D815CB2CEB730E941E2F8BD41B6848B2546D0657E7F85FEDA69FF9048F358AECCBE0B7E9B4AC3F7420513AB539E6B87C8E638FB9AF2F557A3CB389D4ECA72DE1C34523AEDF48E2AB290AA94EC496CBAF527D3D0B95B7395DD7A77ED06A0894102C653DFC6425A317DD383B4F79C8AF8A7A5A62E5AA1899

-- backup the public key of the certificate to a file alice can access
-- remember that the private key is needed for signing and the public key
-- is only used for verification, hence alice won't be able to arbitrarily sign code
--

backup certificate cert_sign_alice to file = 'cert_sign_alice.cer'

--
-- if you rerun this script, you'll get an error if you already created the file
-- you can either change the name of the file or drop the old file

revert

--
-- we're done, now alice just has to take the signature and the certificate
-- and apply the signature to the exact same procedure - she cannot change the code
-- or the signature won't work
-- bob can provide all these (procedure, certificate, and signature) to alice

--#################################
--#Setting db_alice to use signing#
--#################################

use db_alice

execute as login = 'alice'

create certificate cert_sign_alice from file = 'cert_sign_alice.cer'

create user u_cert_sign_alice from certificate cert_sign_alice

add signature to proc_crossdb by certificate cert_sign_alice
  with signature = 0x17B803D0550C450AD4D815CB2CEB730E941E2F8BD41B6848B2546D0657E7F85FEDA69FF9048F358AECCBE0B7E9B4AC3F7420513AB539E6B87C8E638FB9AF2F557A3CB389D4ECA72DE1C34523AEDF48E2AB290AA94EC496CBAF527D3D0B95B7395DD7A77ED06A0894102C653DFC6425A317DD383B4F79C8AF8A7A5A62E5AA1899

-- note that the certificate will appear as authenticator,
-- which will enable the context to be trusted in bob's database,
-- allowing the call to go through
--
exec proc_crossdb

-- Let's see what happens if alice attempts to do something different in the procedure,
-- such as attempting to drop the table
--
alter procedure proc_crossdb
  with execute as 'charles'
as
begin
    select * from sys.login_token
    select db_name()
    select * from sys.user_token
    exec db_bob.dbo.proc_drop_t
end

-- won't work because impersonated context is not authenticated
--
exec proc_crossdb

-- let's try to add the signature
--
add signature to proc_crossdb by certificate cert_sign_alice
  with signature = 0x17B803D0550C450AD4D815CB2CEB730E941E2F8BD41B6848B2546D0657E7F85FEDA69FF9048F358AECCBE0B7E9B4AC3F7420513AB539E6B87C8E638FB9AF2F557A3CB389D4ECA72DE1C34523AEDF48E2AB290AA94EC496CBAF527D3D0B95B7395DD7A77ED06A0894102C653DFC6425A317DD383B4F79C8AF8A7A5A62E5AA1899

--
-- it won't work because signature is not valid
-- alice's attempt has failed - she can only use the signature
-- with the code provided by bob

revert

--#########
--#Cleanup#
--#########

use master;
GO

drop database db_alice;
drop database db_bob;
drop login alice;
drop login bob;
drop login charles;

--
-- EOD

http://stackoverflow.com/questions/1601186/sql-server-script-to-create-a-new-user
http://blog.sqlxdetails.com/procedure-with-execute-as-login/
\http://stackoverflow.com/questions/13037863/clarification-as-to-why-execute-as-user-login-is-not-returning-the-expected-resu
http://blog.sqlauthority.com/2007/03/22/sql-server-fix-error-msg-128-the-name-is-not-permitted-in-this-context-only-constants-expressions-or-variables-allowed-here-column-names-are-not-permitted/
http://sqlknowitall.com/
http://stackoverflow.com/questions/1134319/difference-between-a-user-and-a-login-in-sql-server
https://msdn.microsoft.com/en-us/library/aa337562.aspx#Background
http://blogs.msdn.com/b/lcris/archive/2007/03/23/basic-sql-server-security-concepts-logins-users-and-principals.aspx
http://blogs.msdn.com/b/lcris/archive/2007/10/25/basic-sql-server-security-concepts-sids-orphaned-users-and-loginless-users.aspx

http://blogs.msdn.com/b/lcris/archive/2010/08/24/sql-server-2005-execution-context.aspx
