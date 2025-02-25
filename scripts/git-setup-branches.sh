#!/bin/bash

set -x

git clone git@github.com:VictoriaMetrics/VictoriaMetrics.git src
cd src

git remote add enterprise git@github.com:VictoriaMetrics/VictoriaMetrics-enterprise.git
git fetch --all

git checkout -b cluster origin/cluster
git checkout -b enterprise-master enterprise/master
git checkout -b enterprise-single-node enterprise/enterprise-single-node
git checkout -b enterprise-cluster enterprise/enterprise-cluster
git checkout -b lts-1.102-enterprise enterprise/lts-1.102-enterprise
git checkout -b lts-1.110-enterprise enterprise/lts-1.110-enterprise
git checkout -b lts-series-update-api-v1.89.2-cluster enterprise/lts-series-update-api-v1.89.2-cluster
git checkout -b pmm-6401-read-prometheus-data-files enterprise/pmm-6401-read-prometheus-data-files

git switch master
