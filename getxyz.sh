#!/bin/bash

#########################################################################
#                              getallxyz                                #
# Made by:  Leonardo Israel Lugo Fuentes (LeoLugoF)   			#
# 									#
# Date:     21/Junary/2020                                              #
#                                                                       #
# Searches all the gaussian outputs (*.out,*.log) in the giving		#
# directory and subdirectories. Then, storages the last xyz coordinates #
# found in the output in the giving file with its name.			#
#                                                                       #
# Command line (i.e): bash getallxyz.sh [*.*] [-e]                      #
# Example 1 :   bash getallxyz.sh compounds.txt                         #
# Example 2 :   bash getallxyz.sh compounds.txt -e                      #
# 									#
# Example 2 gets the last SCF or ONIOM energy from the output for       #
# each compound 							#
#########################################################################

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

	for file in $(find $directory -type f -name "*.log" | sort -V);
	do 
		filenamext=$(basename $file)

		echo -n "$(tput sgr0)($i/$NFilesFound) extracting from file: $file"

		awk -F " " 'NF==6' $file | tac | awk '/Rotational/{p=1} p; /Number/{exit}' | tac | awk '/Number/{p=1} p; /Rotational/{exit}' | tail -n +2 | tac | tail -n +2 | tac | awk -v OFS="    " '{print $2, $4, $5, $6}' > "1$1"
		
		sed -i 's/ -/-/g' 1$1
		sed -i 's/^\([0-9][0-9]\) \( \)/\1\2/' 1$1
		i=$(($i+1))
		
		if [ "$(wc -w "1$1" | awk '{print $1}')" == 0 ];
		then
			echo "$(tput setaf 1) No coordinates found"
		else

			echo "${filenamext%%.*}" >> "$1"

			SCFenergy=$(grep "extrapolated energy" $file | tail -1)
			if [ "$2" == '-e' ]; then
				if [[ $SCFenergy == *"extrapolated"* ]];
				then
					SCFenergy=$(grep "extrapolated energy" $file | tail -1 | awk '{print $5}')
					echo "SCF energy = $SCFenergy" >> "$1"
				else
					SCFenergy=$(grep "SCF Done" $file | tail -1 | awk '{print $5}')
					echo "SCF energy = $SCFenergy" >> "$1"
				fi
			fi
			echo " " >> "$1"
			awk '{print $0}' 1$1 >> "$1"
			echo " " >> "$1"
			finaline=$(tail -1 $file)
			echo -n "$(tput setaf 2)	Done! "
			if [[ $finaline == *"Normal"* ]];
			then
				echo "$(tput setaf 2)	Normal Termination."
			else
				echo "$(tput setaf 1)	Not terminated."
			fi
		fi
		rm "1$1"
	done
fi

