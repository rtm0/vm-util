#!/bin/bash

BASEDIR=$(realpath $(dirname $0))
source ${BASEDIR}/tags-branches.sh

function git_log() {
	local tag=$1
	local branch=$2
	local logfile="/tmp/${tag}--${branch}"
	git log --format=%s ${tag}..${branch} > ${logfile}
	echo ${logfile}
}

OSS_SINGLE_LOG=$(git_log ${OSS_SINGLE_TAG} ${OSS_SINGLE_BRANCH})
OSS_CLUSTER_LOG=$(git_log ${OSS_CLUSTER_TAG} ${OSS_CLUSTER_BRANCH})
ENT_SINGLE_LOG=$(git_log ${ENT_SINGLE_TAG} ${ENT_SINGLE_BRANCH})
ENT_CLUSTER_LOG=$(git_log ${ENT_CLUSTER_TAG} ${ENT_CLUSTER_BRANCH})
LTS1_SINGLE_LOG=$(git_log ${LTS1_SINGLE_TAG} ${LTS1_SINGLE_BRANCH})
LTS1_CLUSTER_LOG=$(git_log ${LTS1_CLUSTER_TAG} ${LTS1_CLUSTER_BRANCH})
LTS2_SINGLE_LOG=$(git_log ${LTS2_SINGLE_TAG} ${LTS2_SINGLE_BRANCH})
LTS2_CLUSTER_LOG=$(git_log ${LTS2_CLUSTER_TAG} ${LTS2_CLUSTER_BRANCH})
PMM_SINGLE_LOG=$(git_log ${PMM_SINGLE_TAG} ${PMM_SINGLE_BRANCH})
BMC_CLUSTER_LOG=$(git_log ${BMC_CLUSTER_TAG} ${BMC_CLUSTER_BRANCH})

function diff_logs() {
	local title=$1
	local lhs=$2
	local rhs=$3

	echo
	echo "$title"
	echo "diff $lhs $rhs"
	echo "meld $lhs $rhs"
	diff $lhs $rhs
	meld -n $lhs $rhs &
	echo
}

diff_logs "OSS Single vs OSS Cluster" ${OSS_SINGLE_LOG} ${OSS_CLUSTER_LOG}

diff_logs "OSS Single vs ENT Single" ${OSS_SINGLE_LOG} ${ENT_SINGLE_LOG}
diff_logs "OSS Cluster vs ENT Cluster" ${OSS_CLUSTER_LOG} ${ENT_CLUSTER_LOG}
diff_logs "ENT Single vs ENT Cluster" ${ENT_SINGLE_LOG} ${ENT_CLUSTER_LOG}

diff_logs "ENT Single vs LTS1 Single" ${ENT_SINGLE_LOG} ${LTS1_SINGLE_LOG}
diff_logs "ENT Cluster vs LTS1 Cluster" ${ENT_CLUSTER_LOG} ${LTS1_CLUSTER_LOG}
diff_logs "LTS1 Single vs LTS1 Cluster" ${LTS1_SINGLE_LOG} ${LTS1_CLUSTER_LOG}

diff_logs "ENT Single vs LTS2 Single" ${ENT_SINGLE_LOG} ${LTS2_SINGLE_LOG}
diff_logs "ENT Cluster vs LTS2 Cluster" ${ENT_CLUSTER_LOG} ${LTS2_CLUSTER_LOG}
diff_logs "LTS2 Single vs LTS2 Cluster" ${LTS2_SINGLE_LOG} ${LTS2_CLUSTER_LOG}

diff_logs "OSS Single vs PMM" ${OSS_SINGLE_LOG} ${PMM_SINGLE_LOG}

echo "BMC?"
