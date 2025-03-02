#!/bin/bash

BASEDIR=$(realpath $(dirname $0))
source ${BASEDIR}/tags-branches.sh

git fetch --all --tags

function sync_branch() {
	echo
	git switch $1 && git pull
	git switch -
	echo
}

sync_branch ${OSS_SINGLE_BRANCH}
sync_branch ${OSS_CLUSTER_BRANCH}
sync_branch ${ENT_SINGLE_BRANCH}
sync_branch ${ENT_CLUSTER_BRANCH}
sync_branch ${LTS1_SINGLE_BRANCH}
sync_branch ${LTS1_CLUSTER_BRANCH}
sync_branch ${LTS2_SINGLE_BRANCH}
sync_branch ${LTS2_CLUSTER_BRANCH}
sync_branch ${BMC_CLUSTER_BRANCH}
sync_branch ${PMM_CLUSTER_BRANCH}
