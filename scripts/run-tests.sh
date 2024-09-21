#!/bin/bash

set -e

mkdir -p src logs
if [ -z "$(ls -A src)" ]
then
	git clone https://github.com/VictoriaMetrics/VictoriaMetrics.git \
		--branch master \
		--single-branch \
		src
fi

cd src

upd_ts=0
while true
do
	# Check for new commits every hour.
	curr_ts=$(date +%s)
	if [[ $(($curr_ts - $upd_ts)) -gt 3600 ]]
	then
		git pull origin master
		upd_ts=$(date +%s)
	fi

	log=../logs/$(TZ=UTC date +%Y-%m-%dT%H:%M:%SZ)-$(git log -1 --format="%h").log
	echo $log
	sleep 1
	continue
	go test ./lib/promscrape -count 1 | tee $log
	if [[ ${PIPESTATUS[0]} -eq 0 ]]
	then
		rm $log
	else
		# TODO: Copy to GCS
		# TODO: Send email with the link to the log
	fi
done
