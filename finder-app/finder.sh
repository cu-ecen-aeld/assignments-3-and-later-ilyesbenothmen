#!/bin/bash

if [ $# -ne 2 ] ; then 
	echo "the number of parameter is not OK " 
	exit 1
fi
filesdir=$1
searchstr=$2

if [ ! -d $filesdir ];then
       	echo "the directory ${filesdir} doesn't exist"
	exit 1
fi

file_list=`find ${filesdir} -type f`
total_files=0
total_matching_lines=0
for file in $file_list ; do
	matching_lines=$(grep -c $searchstr $file)
	((total_files++))
        ((total_matching_lines += matching_lines))	
done
echo "The number of files are $total_files and the number of matching lines are $total_matching_lines."
