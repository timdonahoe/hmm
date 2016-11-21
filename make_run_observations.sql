set head off
set feedback off
set pagesize 0
set verify off
set linesize 285
set termout off
spool run_observations.sh
select './observations.sh ' || item_list || ' &1' 
from hmm_tid_lists
group by item_list;
spool off
exit
