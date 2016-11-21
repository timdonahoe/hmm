truncate table hmm_state_probs;
truncate table hmm_results;
truncate table hmm_test_state; 
truncate table hmm_obs_seq;

insert into hmm_test_state (symbol, current_state_days, start_date, end_date)
select symbol, count(*), start_date, end_date
from hmm_states, calendar
where '&1' between start_date and end_date
and caldate between start_date and '&1'
and business_day = 'Y'
group by symbol, start_date, end_date;

insert into hmm_state_probs (symbol, state, prev_state, trans_count)
select symbol, state, prev_state, count(*) trans_count
from hmm_states
where end_date between to_date('&1')-1460 and to_date('&1')-1
group by symbol, state, prev_state;

update hmm_state_probs main
set total_count = 
    (select sum(trans_count)
     from hmm_state_probs sub
     where main.symbol = sub.symbol
     and   main.prev_state = sub.prev_state);

update hmm_state_probs
set trans_prob = trans_count / total_count;

set head off
set feedback off
set pagesize 0
set verify off
set termout off
spool run_tprobs.sql
select '@tprobs ' || symbol
from stock_sum_symbols
order by symbol;
spool off
@run_tprobs


spool run_sprobs.sql
select '@sprobs ' || symbol || ' &1' 
from stock_sum_symbols
order by symbol;
spool off
@run_sprobs

exit
