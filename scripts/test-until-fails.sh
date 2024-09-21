#!/bin/bash

true
while [[ $? == 0 ]]
do
	go test "$@" -count 1
done

