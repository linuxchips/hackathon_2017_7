#!/bin/bash


function p1 {
	# the minute with the max incomming calls
	awk -F ',' '{mina[substr($1,0,16)]++} END { for(k in mina) { print k " " mina[k] } }' | sort -n -r -k 3 | head -n1 > /tmp/t1
}

function p2 {
	# the time of the max simultanius (or concurrent) calls
	fgrep "ANSWERED" | sed -e 's/-/ /' | sed -e 's/-/ /' -e 's/:/ /g' | awk -F ',' '{ start = mktime($1)+$4-$5; end = start+$5; print start " " end " " NR}' | sort -n -k 1 | awk 'START {l=0;} {for (s=$1; s<$2; s++) { scnds[s][1]++; if (scnds[s][1]>l) {l=scnds[s][1]} } if($1 == $2) {scnds[$1*1][0]++} } END {for (sec in scnds) { if (scnds[sec][1]==l) {print sec " " scnds[sec][1] " " scnds[sec][0]} } }' | sort -n -k1 | while read time count zcount; do echo $(date -d @$time '+%F %T') " : " $count; done | sed -r 's/:[0-9]{2}//2' | uniq
}

function p3 {
	# find if there is any relationship between a client and an employee
	fgrep "ANSWERED" | awk -F ',' '{ if($5 >= 3) {rel[$2,$3]++; cnt[$2]++} } END { for(k in rel) { rr=rel[k]/cnt[substr(k,0,36)]; if (rel[k] > 10 && o10r < rr ) { o10clid = substr(k,0,36); o10eid = substr(k,37,3); o10cnt = rel[k]; o10r=rr; } if (rel[k] > 5 && o5r < rr ) { o5clid = substr(k,0,36); o5eid = substr(k,37,3); o5cnt = rel[k]; o5r=rr; } } print "\tconsidering only customers with more than 5 calles, customer " o5clid " and employee " o5eid " ranked " o5r "% of a total calls " o5cnt; print "\tconsidering only customers with more than 10 calles, customer " o10clid " and employee " o10eid " ranked " o10r "% of a total calls " o10cnt; }' > /tmp/t3
}

function p45 {
	# best and worst employee according to the number of answered calls
	fgrep "ANSWERED" | awk -F ',' '{ if($5 >= 3) {emp[$3]++} } END { for(k in emp) { if (emp[k] > 100) { print k " " emp[k] } } }' | sort -n -r -k 2 | tee >(head -n1 > /tmp/t4) | tail -n1 > /tmp/t5
}

function p67 {
	# client with the highst number of calls, and client with longest overall time
	awk -F ',' '{clidn[$2]++; clidt[$2]+=$5} END { for(k in clidn) { print k " " clidn[k] " " clidt[k] } }' | tee >(sort -n -r -k 2 | head -n1 > /tmp/t7) | (sort -n -r -k 3 | head -n1 > /tmp/t6)
}

function printRes {
	echo "1- peak minute of incomming calls: (" $( cat /tmp/t1 | awk '{print $1 " " $2}' ) ") with (" $( cat /tmp/t1 | awk '{print $3}' ) ") calls."
	echo "2- not solved yet..."
	echo "3- analysing relashinship results:"
	cat /tmp/t3
	echo "4- best employee who answered most calls: (" $(cat /tmp/t4 | awk '{print $1}') ") with (" $(cat /tmp/t4 | awk '{print $2}') ") calls."
	echo "5- worst employee who answered the least calls : (" $(cat /tmp/t5 | awk '{print $1}') ") with (" $(cat /tmp/t5 | awk '{print $2}') ") calls. ( discarding employees with less than 100 calls, they are probably fired by now :D )"
	echo "6- client with longest talk time: (" $(cat /tmp/t6 | awk '{print $1}') ") at (" $(cat /tmp/t6 | awk '{print $3}') ") seconds."
	echo "7- client with most frequent calles: (" $(cat /tmp/t7 | awk '{print $1}') ") with (" $(cat /tmp/t7 | awk '{print $2}') ") calls"

}

inF='data.csv'

time cat $inF | tee >(p1) >(p3) >(p45) >(p67) | cat > /dev/null

printRes

echo 
echo 

read -p "Do you wish to solve problem 2?" yn
case $yn in
	[Yy]* ) echo; (time cat $inF | p2);
esac

echo
echo thanks...
