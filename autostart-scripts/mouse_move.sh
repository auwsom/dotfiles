#!/bin/bash

while true; do
HOUR="$(date +'%H')"; 
if [ $HOUR -lt 20 -a $HOUR -gt 8 ] ; 
then xdotool mousemove_relative 1 1; 
fi; 
sleep 3; 
#echo mousemove;
done 

#while [ true ]; do xdotool mousemove 100 100; sleep 300; done
