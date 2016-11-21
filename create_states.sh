sqlplus stock/stock << EOF

truncate table hmm_states;

declare

atr_multiple number := 2.5;

cursor symbols_curs is 
select distinct(stock.symbol)
from stock, stock_sum_symbols
where stock.symbol = stock_sum_symbols.symbol;
vsymbol varchar2(10);
vstate  varchar2(1);
vprev_state varchar2(1);
vprev_date date;
vprev_state_date date;
vstate_close number;
first_record varchar2(1);

cursor days_curs is
select open, close, n, trade_date, high, low
from stock
where stock.symbol = vsymbol
order by stock.trade_date;
days_rec days_curs%rowtype;

begin
open symbols_curs;
loop
  fetch symbols_curs into vsymbol;
  exit when symbols_curs%notfound;
  vstate := 'N';
  vprev_state := 'N';
  first_record := 'Y';

  open days_curs;
  loop
    fetch days_curs into days_rec;
    exit when days_curs%notfound; 
    
    if first_record = 'Y' then
       first_record := 'N';
       vstate_close := days_rec.open;
    end if;

       if days_rec.high > vstate_close + (atr_multiple*days_rec.n) then
          update hmm_states
          set end_date = days_rec.trade_date
          where symbol = vsymbol
          and end_date is null;
          insert into hmm_states values (vsymbol, 'U', vstate, next_business_day(days_rec.trade_date), null,
              days_rec.close, days_rec.n, NULL, NULL);
          vprev_state := vstate;
          vstate := 'U';
          vstate_close := days_rec.close;
          vprev_state_date := next_business_day(days_rec.trade_date);
       elsif days_rec.low < vstate_close - (atr_multiple*days_rec.n) then
          update hmm_states
          set end_date = days_rec.trade_date
          where symbol = vsymbol
          and end_date is null;
          insert into hmm_states values (vsymbol, 'D', vstate, next_business_day(days_rec.trade_date), null,
              days_rec.close, days_rec.n, NULL, NULL);
          vprev_state := vstate;
          vstate := 'D';
          vstate_close := days_rec.close;
          vprev_state_date := next_business_day(days_rec.trade_date);
       elsif days_rec.trade_date > vprev_state_date + 20 then
          update hmm_states
          set end_date = days_rec.trade_date
          where symbol = vsymbol
          and end_date is null;
          insert into hmm_states values (vsymbol, 'N', vstate, next_business_day(days_rec.trade_date), null,
              days_rec.close, days_rec.n, NULL, NULL);
          vprev_state := vstate;
          vstate := 'N';
          vstate_close := days_rec.close;
          vprev_state_date := next_business_day(days_rec.trade_date);
       end if; 

    vprev_date := days_rec.trade_date; 
  end loop;
  close days_curs;
  commit;

end loop;
close symbols_curs;
end;
/ 

delete from hmm_states
where end_date < start_date;

update hmm_states main
set next_state = 
    (select state
     from hmm_states sub
     where sub.symbol = main.symbol
     and sub.start_date = 
        (select min(start_date)
         from hmm_states sub2
         where sub2.symbol = sub.symbol
         and sub2.start_date > main.start_date))
where end_date is not null;

exit
EOF
date
