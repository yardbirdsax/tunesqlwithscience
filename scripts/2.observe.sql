use TuneSQLDemo;

-- Clear procedure cache and execute using the 'smaller' result.
-- Make sure you have "Include Actual Execution Plan enabled.
-- We also enable STATISTICS IO to gather table by table IO stats,
-- and STATISTICS TIME to gather execution stats.
-- What observations do you see when examining the plan and IO statistics?
dbcc freeproccache;
checkpoint;
dbcc dropcleanbuffers;

set statistics IO on;
set statistics time on;

exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 1;  


exec dbo.GetTransactionByAdministrator @pi_Administrator_ID = 2;

set statistics io off;
set statistics time off;