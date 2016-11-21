set pagesize 10000
set echo off
set feedback off
set termout off
spool ex&1

select caldate, s.symbol
from hmm_states t, hmm_states s, calendar c, hmm_eclat_symbols e
where caldate between s.start_date and s.end_date
and business_day = 'Y'
and '&1' between t.start_date and nvl(t.end_date, sysdate)
and s.symbol = t.symbol
and t.symbol = e.symbol
and t.state != 'N'
and s.state = t.state
and caldate between to_date('&1')-1460 and to_date('&1')
group by caldate, s.symbol;

spool off
exit
