sqlplus stock/stock << EOF
set pagesize 0
set feedback off
set echo off
set termout off
spool run_extract.sh
select './extract.sh ' || caldate
from calendar
where business_day = 'Y'
and caldate between '01-Aug-16' and '18-Nov-16'
order by caldate;
spool off
EOF
exit
chmod 755 run_extract.sh
