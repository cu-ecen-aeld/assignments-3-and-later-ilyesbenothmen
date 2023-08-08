#!/bin/bash

if [ $# -ne 2 ];then 
	echo "error the number specified ..."
	exit 1
fi

writefile=$1
writestr=$2
dir_path=$(dirname "$writefile")
mkdir -p "$dir_path"
echo "$writestr" > "$writefile"
# Check if the file was created successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to create the file '$writefile'."
    exit 1
fi

echo "File '$writefile' created successfully with the content:"
echo "$writestr"
