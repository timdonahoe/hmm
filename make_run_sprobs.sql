set head off
set feedback off
set pagesize 0
set verify off
set termout off
spool run_sprobs.sql
select '@sprobs ' || symbol || ' &1' 
from stock_sum_symbols
order by symbol;
spool off
@run_sprobs

exit
