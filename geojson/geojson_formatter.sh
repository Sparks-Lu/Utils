#!/bin/sh
fn_input=$1
cp $fn_input ${fn_input}.bak
sed 's/",\s*"features"/",\n"features"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
cp $fn_input ${fn_input}.bak
sed 's/{\s*"type"/{\n"type"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/",\s*"properties"/",\n"properties"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/},\s*"properties"/},\n"properties"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/},\s*"geometry"/},\n"geometry"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/",\s*"geometry"/",\n"geometry"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/",\s*"coordinates"/",\n"coordinates"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/]\s*}/]\n}/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/}\s*}/}\n}/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/},\s*{/},\n{/g' ${fn_input}.bak > $fn_input
