col D format 9.9999
col N format 9.9999
col U format 9.9999
spool matrix_files/t&1
select sum(decode(state, 'D', trans_prob, 0)) D, 
       sum(decode(state, 'N', trans_prob, 0)) N, 
       sum(decode(state, 'U', trans_prob, 0)) U
from   hmm_state_probs
where  symbol = '&1'
group by prev_state;
