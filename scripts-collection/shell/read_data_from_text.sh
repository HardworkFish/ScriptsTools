#!/bin/bash
# read data from a file

read -p "Please input filename: " filename
count=1
cat $filename | while read line
do
	echo "Line $count: $line"
	count=$[ $count + 1 ]
done
echo "Finished processing the file"
