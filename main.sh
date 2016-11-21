if [ -a tidlists_files/$1.log ]; then

awk -f tidlists.awk tidlists_files/$1.log > insert_tidlists.sql

cat sql_head.sql insert_tidlists.sql sql_tail.sql > t
mv t insert_tidlists.sql

sqlplus stock/stock @insert_tidlists 

rm matrix_files/*

sqlplus stock/stock @make_run_tprobs $1
sqlplus stock/stock @make_run_sprobs $1
find matrix_files/* -not -name "*.lst" -exec mv {} {}.lst \;
sqlplus stock/stock @make_run_observations $1
head -30 run_observations.sh > t
mv t run_observations.sh
rm run_observationsaa
rm run_observationsab
rm run_observationsac
rm run_observationsad
rm run_observations_1.sh
rm run_observations_2.sh
rm run_observations_3.sh
rm run_observations_4.sh
split -l 8 run_observations.sh run_observations
awk '{print $0 " 1"}' run_observationsaa > run_observations_1.sh
awk '{print $0 " 2"}' run_observationsab > run_observations_2.sh
awk '{print $0 " 3"}' run_observationsac > run_observations_3.sh
awk '{print $0 " 4"}' run_observationsad > run_observations_4.sh
chmod 755 run_observations_1.sh 
chmod 755 run_observations_2.sh 
chmod 755 run_observations_3.sh
chmod 755 run_observations_4.sh
./run_observations_1.sh > run_observations_1.log 2>&1 &
pid1=$!
./run_observations_2.sh > run_observations_2.log 2>&1 &
pid2=$!
./run_observations_3.sh > run_observations_3.log 2>&1 &
pid3=$!
./run_observations_4.sh > run_observations_4.log 2>&1 &
pid4=$!
wait $pid1
wait $pid2
wait $pid3
wait $pid4
cat run_observations_1.log >> run_observations.log
cat run_observations_2.log >> run_observations.log
cat run_observations_3.log >> run_observations.log
cat run_observations_4.log >> run_observations.log

echo "Recording test results......."
sqlplus stock/stock << EOF

insert into hmm_results_test
select to_date('$1'),
       symbol,
       state,
       fprob,
       min(item_list),
       pprob
from   hmm_results main
where  pprob > .80
and    fprob = 
       (select max(fprob)
        from hmm_results sub
        where sub.symbol = main.symbol
        and sub.state = main.state)
group by to_date('$1'),
       symbol,
       state,
       fprob,
       pprob;

exit
EOF
date 

fi
