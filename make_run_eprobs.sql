!rm matrix_files_&3/*
!rm obsmatrix_files_&3/*
!rm hmm_logs_&3/*

DEFINE ITEM_LIST = '&1'
DEFINE TEST_DATE = '&2'

set timing on
alter session set sql_trace=FALSE;

insert into hmm_test_state_temp
select * from hmm_test_state;

insert into hmm_tid_lists_temp
select match_date 
from hmm_tid_lists
where item_list = '&1';

update hmm_test_state_temp
set current_obs_days = 
    (select count(*)
     from hmm_tid_lists_temp
     where match_date between start_date and end_date),
    run_hmm = NULL;

insert into hmm_states_temp
select * from hmm_states;

update hmm_states_temp s
set eprob_bucket = 
  (select decode(greatest(count(*), current_obs_days), count(*), 'Y', 'N')
   from hmm_test_state_temp ts, hmm_tid_lists_temp t
   where match_date between s.start_date and least(s.end_date, to_date('&2'))
   and ts.symbol = s.symbol
   group by current_obs_days)
where s.end_date > to_date('&2')-1460
and s.start_date <= '&2';

update hmm_states_temp
set eprob_bucket = 'N'
where end_date > to_date('&2')-1460
and start_date <= '&2'
and eprob_bucket is null;

declare
vsymbol varchar2(10);
vitem_list varchar2(255);
v_states_eprob_bucket varchar2(1);
v_obs_eprob_bucket varchar2(1);
vfound_match_flag varchar2(1);
vitem_list_match_flag varchar2(1);

cursor states_curs is
select eprob_bucket
from hmm_states_temp
where symbol = vsymbol
and eprob_bucket is not null
order by start_date;

cursor obs_seq_curs is
select eprob_bucket
from hmm_obs_seq
where symbol = vsymbol
and  item_list = vitem_list
order by start_date;

cursor obs_seq_item_list_curs is
select item_list
from hmm_obs_seq
where symbol = vsymbol
group by symbol, item_list;

cursor symbol_curs is
select symbol
from hmm_test_state_temp
where run_hmm is null;

begin
  open symbol_curs;
  loop
    fetch symbol_curs into vsymbol;
    exit when symbol_curs%notfound;
    open obs_seq_item_list_curs;
    loop
      vfound_match_flag := 'N';
      fetch obs_seq_item_list_curs into vitem_list; 
      exit when obs_seq_item_list_curs%notfound;
      open states_curs;
      open obs_seq_curs;
      vitem_list_match_flag := 'Y';
      loop
        fetch states_curs into v_states_eprob_bucket;
        exit when states_curs%notfound;
        fetch obs_seq_curs into v_obs_eprob_bucket;
        if v_states_eprob_bucket != v_obs_eprob_bucket then
           vitem_list_match_flag := 'N';
           exit;
        end if;
      end loop;
      close states_curs;
      close obs_seq_curs;
      if vitem_list_match_flag = 'Y' then
         vfound_match_flag := 'Y';
         exit;
      end if;
    end loop;
    close obs_seq_item_list_curs;
    if vfound_match_flag = 'N' then
       insert into hmm_obs_seq
       select symbol, eprob_bucket, '&1', start_date
       from hmm_states_temp
       where symbol = vsymbol
       and eprob_bucket is not null
       order by start_date; 
       update hmm_test_state_temp
       set run_hmm = 'Y' 
       where symbol = vsymbol;
    end if;
  end loop;         
  close symbol_curs;
end;
/
    

insert into hmm_obs_state_probs_temp (symbol, eprob_bucket, state, trans_count)
select symbol, eprob_bucket, next_state, count(*) trans_count
from hmm_states_temp
where eprob_bucket is not null
and end_date < '&2'
group by symbol, eprob_bucket, next_state;

update hmm_obs_state_probs_temp main
set total_count =
    (select sum(trans_count)
     from hmm_obs_state_probs_temp sub
     where main.symbol = sub.symbol
     and   main.state = sub.state);

update hmm_obs_state_probs_temp
set trans_prob = trans_count / total_count;

insert into hmm_obs_state_probs_temp
select symbol, 'N', 0, 0, 0, 'N'
from hmm_obs_state_probs_temp main
where exists 
      (select 'x'
       from hmm_obs_state_probs_temp sub
       where sub.symbol = main.symbol)
and not exists
      (select 'x'
       from hmm_obs_state_probs_temp sub2
       where sub2.symbol = main.symbol
       and state = 'N')
group by symbol;

insert into hmm_obs_state_probs_temp
select symbol, 'U', 0, 0, 0, 'N'
from hmm_obs_state_probs_temp main
where exists 
      (select 'x'
       from hmm_obs_state_probs_temp sub
       where sub.symbol = main.symbol)
and not exists
      (select 'x'
       from hmm_obs_state_probs_temp sub2
       where sub2.symbol = main.symbol
       and state = 'U')
group by symbol;

insert into hmm_obs_state_probs_temp
select symbol, 'D', 0, 0, 0, 'N'
from hmm_obs_state_probs_temp main
where exists 
      (select 'x'
       from hmm_obs_state_probs_temp sub
       where sub.symbol = main.symbol)
and not exists
      (select 'x'
       from hmm_obs_state_probs_temp sub2
       where sub2.symbol = main.symbol
       and state = 'D')
group by symbol;

set timing off

set head off
set feedback off
set pagesize 0
set verify off
set termout off
spool run_eprobs_&3
select '@eprobs ' || symbol || ' &3'
from stock_sum_symbols
order by symbol;
spool off
!./mv.sh run_eprobs &3
@run_eprobs_&3

spool  run_obs_&3
select '@obs ' || symbol || ' &3'
from hmm_test_state_temp
where run_hmm = 'Y'
order by symbol;
spool off
!./mv.sh run_obs &3
@run_obs_&3

spool hmm_list_&3
select hmm_test_state_temp.symbol 
from hmm_test_state_temp, stock_sum_symbols 
where run_hmm = 'Y'
and hmm_test_state_temp.symbol = stock_sum_symbols.symbol
order by hmm_test_state_temp.symbol;
spool off

!./find.sh &3

!./hmm.sh &3

!./rm.sh insert_hmm_results &3 sql
#@make_run_parse_hmm &1 &3

set head off
set feedback of
set pagesize 0
set verify of
set termout of
set linesize 300

spool run_parse_hmm_&3
select 'awk -v s="' || hmm_test_state_temp.symbol || '" -v i="' || '&ITEM_LIST' || '" -f parse_hmm.awk hmm_logs_&3/' || hmm_test_state_temp.symbol || '.log >> insert_hmm_results_&3'
from hmm_test_state_temp, stock_sum_symbols
where run_hmm = 'Y'
and hmm_test_state_temp.symbol = stock_sum_symbols.symbol;
spool off
!./mv_sh.sh run_parse_hmm &3
!./chmod.sh run_parse_hmm &3
!./run_parse_hmm_&3
set head on
set verify on
set termout on

!./mv2.sh insert_hmm_results &3  
@insert_hmm_results_&3

/*********
insert into hmm_states_hold
select symbol, state, prev_state, start_date, end_date, prev_close, n,
       next_state, eprob_bucket, '&TEST_DATE', '&ITEM_LIST'
from hmm_states_temp
where symbol in 
   (select symbol
    from hmm_results
    where item_list = '&ITEM_LIST'
    and pprob > .8);
***********/

exit
