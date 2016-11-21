spool matrix_files/s&1
select decode(state, 'D', 1, 0) D, 
       decode(state, 'N', 1, 0) N, 
       decode(state, 'U', 1, 0) U
from   hmm_states
where  symbol = '&1'
and '&2' between start_date and end_date;
