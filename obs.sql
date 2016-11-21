spool matrix_files_&2/o&1
select eprob_bucket
from hmm_states_temp
where symbol = '&1'
and eprob_bucket is not null
order by start_date;
spool off
