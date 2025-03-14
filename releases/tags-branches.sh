#!/bin/bash

TAG=v1.113.0
LTS1=lts-1.102
LTS1_TAG=v1.102.16
LTS2=lts-1.110
LTS2_TAG=v1.110.3

OSS_SINGLE_REMOTE=origin
OSS_SINGLE_BRANCH=master
OSS_SINGLE_TAG=${TAG}

OSS_CLUSTER_REMOTE=origin
OSS_CLUSTER_BRANCH=cluster
OSS_CLUSTER_TAG=${TAG}-cluster

ENT_SINGLE_REMOTE=enterprise
ENT_SINGLE_BRANCH=enterprise-single-node
ENT_SINGLE_TAG=${TAG}-enterprise

ENT_CLUSTER_REMOTE=enterprise
ENT_CLUSTER_BRANCH=enterprise-cluster
ENT_CLUSTER_TAG=${TAG}-enterprise-cluster

LTS1_SINGLE_REMOTE=enterprise
LTS1_SINGLE_BRANCH=${LTS1}-enterprise
LTS1_SINGLE_TAG=${LTS1_TAG}-enterprise

LTS1_CLUSTER_REMOTE=enterprise
LTS1_CLUSTER_BRANCH=${LTS1}-enterprise-cluster
LTS1_CLUSTER_TAG=${LTS1_TAG}-enterprise-cluster

LTS2_SINGLE_REMOTE=enterprise
LTS2_SINGLE_BRANCH=${LTS2}-enterprise
LTS2_SINGLE_TAG=${LTS2_TAG}-enterprise

LTS2_CLUSTER_REMOTE=enterprise
LTS2_CLUSTER_BRANCH=${LTS2}-enterprise-cluster
LTS2_CLUSTER_TAG=${LTS2_TAG}-enterprise-cluster

PMM_SINGLE_REMOTE=origin
PMM_SINGLE_BRANCH=pmm-6401-read-prometheus-data-files
PMM_SINGLE_TAG=pmm-6401-${TAG}

BMC_CLUSTER_REMOTE=enterprise
BMC_CLUSTER_BRANCH=lts-series-update-api-v1.89.2-cluster
BMC_CLUSTER_TAG=series-update-v1.89.2-cluster-rc18
