#!/bin/ksh

script_home=/Users/frhong/GitHub/GoJS/GoJS/samples
datafile=$script_home/PPMiR_data.txt
temp_order=$script_home/PPMiR_data.order
report=$script_home/PPMiR_components.html
template=$script_home/PPMiR_comp.html.template

sed -n '1,/xxxnodeDataArrayxxx/p' $template > $report

cut -d: -f2- $datafile | sed -e 's/ /\
/g' | sort | uniq > $temp_order

i=0
while read line
do
	jira_id=`echo $line | cut -d: -f1`
	echo "nodeDataArray.push({ key: $i, text: \"$jira_id\", color: go.Brush.randomColor(128, 240) });" >> $report
	i=`expr $i + 1`
done < $datafile

sed -n '/xxxnodeDataArrayxxx/,/xxxlinkDataArrayxxx/p' $template >> $report

while read line
do
	echo "$line"
	temp_grep=$script_home/temp_grep
	temp1=$script_home/temp1
	tempout=$script_home/tempout
	touch $tempout
	grep -n " $line " $datafile | cut -d: -f1 > $temp_grep 
	while read l
	do
		l=`expr $l - 1`
		echo $l >> $temp1
	done < $temp_grep

	while read x
	do
		found=0
		while read y
		do
			echo "$x -- $y"
			if [ "$x" -ne "$y" ]
			then
				grep "$x:$y" $tempout > /tmp/junk
				a=$?
				echo "a=$a ... $x:$y"
				if [ $a -eq 1 ]
				then
					echo "linkDataArray.push({ from: $x, to: $y, color: go.Brush.randomColor(0, 127) });" >> $report
					echo "$x:$y $y:$x" >> $tempout
					found=1
				fi
			fi
		done < $temp1
#		if [ "$found" -eq "0" ]
#		then
#			echo "linkDataArray.push({ from: $x, to: $x, color: go.Brush.randomColor(0, 127) });" >> $report
#		fi
	done < $temp1
	/bin/rm -rf $temp1
	/bin/rm -rf $tempout

done < $temp_order

sed -n '/xxxlinkDataArrayxxx/,$p' $template >> $report
