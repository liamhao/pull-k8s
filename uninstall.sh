#!/bin/bash

kubeadm reset -f
yum remove -y docker docker-common docker-selinux docker-engine docker-ce-cli docker-client containerd.io kubeadm kubectl kubelet
rm -rf /var/lib/docker
