#!/bin/bash

kubeadm reset -f
yum remove -y docker docker-common docker-selinux dockesr-engine kubeadm kubectl kubelet
rm -rf /var/lib/docker
