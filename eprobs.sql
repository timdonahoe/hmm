spool matrix_files_&2/e&1
select sum(decode(eprob_bucket, 'N', trans_prob, 0)) e0, 
       sum(decode(eprob_bucket, 'Y', trans_prob, 0)) e1
from   hmm_obs_state_probs_temp
where  symbol = '&1'
and    state is not null
group by state;
