#!/bin/bash

# helm show values vm/victoria-metrics-single > values.yaml

helm upgrade -i master vm/victoria-metrics-single -f master.yaml -n rtm0-test
helm upgrade -i issue-7599 vm/victoria-metrics-single -f issue-7599.yaml -n rtm0-test
kubectl -n rtm0-test apply -f vm-service-scrape.yaml
