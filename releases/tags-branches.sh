#!/bin/bash

TAG=v1.112.0
LTS1=lts-1.102
LTS1_TAG=v1.102.14
LTS2=lts-1.110
LTS2_TAG=v1.110.2

OSS_SINGLE_TAG=${TAG}
OSS_SINGLE_BRANCH=master
OSS_CLUSTER_TAG=${TAG}-cluster
OSS_CLUSTER_BRANCH=cluster
ENT_SINGLE_TAG=${TAG}-enterprise
ENT_SINGLE_BRANCH=enterprise-single-node
ENT_CLUSTER_TAG=${TAG}-enterprise-cluster
ENT_CLUSTER_BRANCH=enterprise-cluster
LTS1_SINGLE_TAG=${LTS1_TAG}-enterprise
LTS1_SINGLE_BRANCH=${LTS1}-enterprise
LTS1_CLUSTER_TAG=${LTS1_TAG}-enterprise-cluster
LTS1_CLUSTER_BRANCH=${LTS1}-enterprise-cluster
LTS2_SINGLE_TAG=${LTS2_TAG}-enterprise
LTS2_SINGLE_BRANCH=${LTS2}-enterprise
LTS2_CLUSTER_TAG=${LTS2_TAG}-enterprise-cluster
LTS2_CLUSTER_BRANCH=${LTS2}-enterprise-cluster
BMC_CLUSTER_TAG=series-update-v1.89.2-cluster-rc18
BMC_CLUSTER_BRANCH=lts-series-update-api-v1.89.2-cluster
PMM_CLUSTER_TAG=
PMM_CLUSTER_BRANCH=pmm-6401-read-prometheus-data-files
