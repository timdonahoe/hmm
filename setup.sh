sqlplus stock/stock << EOF

update stock
set n = null
where n is not null;

commit;

rem alter session set sql_trace = TRUE;

/******
drop table stock_sum_symbols;
create table stock_sum_symbols as
select symbol
from stock
where trade_date = '04-Jan-10'
and close*volume > 10000000;
 ******   Fix this!  ******
          Get rid of non-current stocks  **/

declare
begin_date date := '01-Jan-03';
end_date date := '07-Nov-16';
vdate date;
vsymbol varchar2(10);
vhigh_20day number;
vhigh number;
vlow_20day number;
vlow number;
vvol_20day number;
vclose number;
vopen number;
vprevious_day_close number;
vprevious_day_n number;
vn number;
vunit number;
first_day_flag varchar2(1);

cursor symbols_curs is
select symbol 
from stock_sum_symbols
order by symbol;

cursor symbol_days_curs is
select trade_date, open, close, high, low
from stock
where symbol = vsymbol
and trade_date >= begin_date
order by trade_date;

begin

open symbols_curs;
loop
  fetch symbols_curs into vsymbol;
  exit when symbols_curs%notfound;
  vdate := begin_date;
  first_day_flag := 'Y';
  open symbol_days_curs;
    loop
      fetch symbol_days_curs into vdate, vopen, vclose, vhigh, vlow;
      exit when symbol_days_curs%notfound;

      if first_day_flag = 'Y' then
         first_day_flag := 'N';
         vprevious_day_close := vopen;
         select avg(greatest(high-low, high-vprevious_day_close, vprevious_day_close-low))
         into vn
         from stock
         where symbol = vsymbol
         and trade_date between vdate-26 and vdate;
      else
         vn := (19 * vprevious_day_n + greatest(vhigh-vlow, 
                   vhigh-vprevious_day_close,
                   vprevious_day_close-vlow)) / 20;
      end if;

      update stock
      set n = vn
      where symbol = vsymbol
      and trade_date = vdate;

      vprevious_day_close := vclose;
      vprevious_day_n := vn;

   end loop;
   close symbol_days_curs;

   commit;

end loop;
close symbols_curs;

end;
/

exit
EOF
date
