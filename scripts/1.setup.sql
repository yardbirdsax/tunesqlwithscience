use [master];

if exists (select 1 from sys.databases where [name] = 'TuneSQLDemo') begin 
  alter database TuneSQLDemo set single_user with rollback immediate;
  drop database TuneSQLDemo;
end

create database TuneSQLDemo;
go

/*********************************************************
 Create objects
 *********************************************************/
use TuneSQLDemo;
go

if exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Account')
  drop table dbo.Account;
  
create table dbo.Account
(
  Account_Key int identity(1,1),
  Account_ID int,
  Administrator_ID int,
  primary key clustered (Account_Key),
  unique (Account_ID,Administrator_ID)
);

if exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Financial_Transaction')
  drop table dbo.Financial_Transaction;
  
create table dbo.Financial_Transaction
(
  Financial_Transaction_ID int identity(1,1),
  Account_Key int,
  Transaction_Amt money,
  primary key clustered (Financial_Transaction_ID),
  foreign key (Account_Key) references dbo.Account(Account_Key)
);

create nonclustered index nci_Financial_Transaction_Account on dbo.Financial_Transaction
(
  Account_Key
);

/**********************************
 Load data
 *********************************/
declare @start_num int;
declare @max_num int;
declare @increment int;

-- Create one accountant with 5 accounts
with Numbers AS
(
  select
    row_number() over(order by sc1.column_id) as N
  from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
)
insert dbo.Account
(
  Administrator_ID,
  Account_ID
)
select top 5
  1 AS Administrator_ID,
  N.N AS Account_ID
from 
  Numbers N;

set @start_num = 0;
set @max_num = 50;
set @increment = 10;

while @start_num <= @max_num begin

  ;with Numbers AS
  (
    select
      row_number() over(order by sc1.column_id) as N
    from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
  )
  insert dbo.financial_transaction
  (
    Account_Key,
    Transaction_Amt
  )
  select
    Account_Key,
    n.N
  from
    dbo.Account ac cross join Numbers n
  where
    ac.Administrator_ID = 1
    and N >= @start_num
    and N < @start_num + @increment
  order by
    ac.Administrator_ID,
    ac.Account_ID;

  set @start_num = @start_num + @increment;
  raiserror('Start: %i',10,1,@start_num) with nowait;

end


-- Create one accountant with 10000 accounts
;with Numbers AS
(
  select
    row_number() over(order by sc1.column_id) as N
  from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
)
insert dbo.Account
(
  Administrator_ID,
  Account_ID
)
select top 10000
  2 AS Administrator_ID,
  N.N AS Account_ID
from 
  Numbers N;

set @start_num = 0;
set @max_num = 100;
set @increment = 25;

while @start_num <= @max_num begin

  begin tran;

  ;with Numbers AS
  (
    select
      row_number() over(order by sc1.column_id) as N
    from    sys.columns sc1 cross join sys.columns sc2 cross join sys.columns sc3
  )
  insert dbo.financial_transaction
  (
    Account_Key,
    Transaction_Amt
  )
  select
    Account_Key,
    n.N
  from
    dbo.Account ac cross join Numbers n
  where
    ac.Administrator_ID = 2
    and N >= @start_num
    and N < @start_num + @increment
  order by
    ac.Administrator_ID,
    ac.Account_ID;

  commit;

  set @start_num = @start_num + @increment;
  raiserror('Start: %i',10,1,@start_num) with nowait;

end
  
go

/****************************************************
 Create procedure to select results by Admin
 ****************************************************/

if exists(select 1 from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'GetTransactionByAdministrator')
  drop procedure dbo.GetTransactionByAdministrator;
go

create procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
as
set nocount on;
select
  acct.Account_ID,
  ft.Transaction_Amt
from
  dbo.Account acct join dbo.Financial_Transaction ft
    on acct.Account_Key = ft.Account_Key
where 
  acct.Administrator_ID = @pi_Administrator_ID;
go