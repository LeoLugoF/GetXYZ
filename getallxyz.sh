#!/bin/bash

if [ -z "$1" ];
then
	echo "Insert the name of the file where all the info is going to be storaged after the script name."
	echo "This script extracts all the xyz coordinates from gaussian output with extension *.out and *.log"
	echo "From the current directory and subdirectories."
else

if [ -f $1 ];
then
	rm $1
fi

NFilesFoundlog=$(find $directory -name "*.log" | wc -l)
NFilesFoundOut=$(find $directory -name "*.out" | wc -l)
NFilesFound=$(($NFilesFoundlog+$NFilesFoundOut))

i=1

echo "Number of files found (*.out,*.log): $NFilesFound"

for file in $(find $directory -type f -name "*.log" && find $directory -type f -name "*.out");
do 
filenamext=$(basename $file)

echo -n "($i/$NFilesFound) extracting from file: $file"

awk -F " " 'NF==6' $file | tac | awk '/Rotational/{p=1} p; /Number/{exit}' | tac | awk '/Number/{p=1} p; /Rotational/{exit}' | tail -n +2 | tac | tail -n +2 | tac | awk '{print $2 " " $4 " " $5 " " $6}' > "1$1"

i=$(($i+1))

if [ "$(wc -w "1$1")" == 0 ];
	then
	echo "	No coordinates found"	
	else
	echo "${filenamext%%.*}" >> "$1"
	echo " " >> "$1"
	awk '{print $0}' 1$1 >> "$1"
	echo " " >> "$1"
	finaline=$(tail -1 $1)
	echo -n "	Done! "
	if [[ $finaline == *"Normal"* ]];
	then
		echo "	Normal Termination."
		else
		echo "	Not terminated."
	fi
	fi
rm "1$1"
done
fi
