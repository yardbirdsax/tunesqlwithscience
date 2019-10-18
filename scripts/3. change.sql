/************************************************
 Solution: Specify WITH RECOMPILE at the 
 stored procedure level.

 Will correct the problem but will add CPU overhead
 upon every execution. This can add up for expensive /
 complex plans in frequently executed procedures.

 ************************************************/

use TuneSQLDemo;
GO

alter procedure dbo.GetTransactionByAdministrator
  @pi_Administrator_ID int
with recompile -- newly added
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

dbcc freeproccache;
checkpoint;
dbcc dropcleanbuffers;
go

set statistics io on;
set statistics time on;

exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;

set statistics io off;
set statistics time off;
go


-- undo change and check if problem still exists
alter procedure dbo.GetTransactionByAdministrator
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

dbcc freeproccache;
checkpoint;
dbcc dropcleanbuffers;
go

set statistics io on;
set statistics time on;

exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  

exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;
go

set statistics io off;
set statistics time off;
