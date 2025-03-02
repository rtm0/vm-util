#!/bin/bash

BASEDIR=$(realpath $(dirname $0))
source ${BASEDIR}/tags-branches.sh

# Also sets up ${OSS_SINGLE_BRANCH}
git clone git@github.com:VictoriaMetrics/VictoriaMetrics.git src
cd src

git remote add enterprise git@github.com:VictoriaMetrics/VictoriaMetrics-enterprise.git
git fetch --all

git checkout -b ${OSS_CLUSTER_BRANCH} origin/${OSS_CLUSTER_BRANCH}
git checkout -b ${ENT_SINGLE_BRANCH} enterprise/${ENT_SINGLE_BRANCH}
git checkout -b ${ENT_CLUSTER_BRANCH} enterprise/${ENT_CLUSTER_BRANCH}
git checkout -b ${LTS1_SINGLE_BRANCH} enterprise/${LTS1_SINGLE_BRANCH}
git checkout -b ${LTS1_CLUSTER_BRANCH} enterprise/${LTS1_CLUSTER_BRANCH}
git checkout -b ${LTS2_SINGLE_BRANCH} enterprise/${LTS2_SINGLE_BRANCH}
git checkout -b ${LTS2_CLUSTER_BRANCH} enterprise/${LTS2_CLUSTER_BRANCH}
git checkout -b ${BMC_CLUSTER_BRANCH} enterprise/${BMC_CLUSTER_BRANCH}
git checkout -b ${PMM_CLUSTER_BRANCH} enterprise/${PMM_CLUSTER_BRANCH}

git switch ${OSS_SINGLE_BRANCH}
