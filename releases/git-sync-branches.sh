#!/bin/bash

BASEDIR=$(realpath $(dirname $0))
source ${BASEDIR}/tags-branches.sh

git fetch --all --tags

function sync_branch() {
	local remote=$1
	local branch=$2
	echo
	git switch $branch && git pull $remote $branch
	git switch -
	echo
}

sync_branch ${OSS_SINGLE_REMOTE} ${OSS_SINGLE_BRANCH}
sync_branch ${OSS_CLUSTER_REMOTE} ${OSS_CLUSTER_BRANCH}
sync_branch ${ENT_SINGLE_REMOTE} ${ENT_SINGLE_BRANCH}
sync_branch ${ENT_CLUSTER_REMOTE} ${ENT_CLUSTER_BRANCH}
sync_branch ${LTS1_SINGLE_REMOTE} ${LTS1_SINGLE_BRANCH}
sync_branch ${LTS1_CLUSTER_REMOTE} ${LTS1_CLUSTER_BRANCH}
sync_branch ${LTS2_SINGLE_REMOTE} ${LTS2_SINGLE_BRANCH}
sync_branch ${LTS2_CLUSTER_REMOTE} ${LTS2_CLUSTER_BRANCH}
sync_branch ${PMM_SINGLE_REMOTE} ${PMM_SINGLE_BRANCH}
sync_branch ${BMC_CLUSTER_REMOTE} ${BMC_CLUSTER_BRANCH}
