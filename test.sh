#!/bin/sh

IFS=
data=$(< prop.properties)
echo data=$data

IFS=$'\n'
d2=( $data )
n=${#d2[*]}
echo d2.n=$n
for (( i = 0; i < n; i++)); do
	echo d2=${d2[$i]}
done
