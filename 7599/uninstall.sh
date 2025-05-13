#!/bin/bash

kubectl -n rtm0-test delete -f vm-service-scrape.yaml
helm uninstall master
helm uninstall issue-7599

