#!/bin/sh
fn_input=$1
cp $fn_input ${fn_input}.bak
sed 's/","features"/",\n"features"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/{"type"/{\n"type"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/","properties"/",\n"properties"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/},"geometry"/},\n"geometry"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/","coordinates"/",\n"coordinates"/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/]}/]\n}/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/}}/}\n}/g' ${fn_input}.bak > $fn_input
cp $fn_input ${fn_input}.bak
sed 's/},{/},\n{/g' ${fn_input}.bak > $fn_input
