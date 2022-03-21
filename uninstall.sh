#!/bin/bash

kubeadm reset -f
yum remove -y docker docker-common docker-selinux docker-engine docker-ce-cli docker-client containerd.io kubeadm kubectl kubelet
systemctl daemon-reload
rm -rf /var/lib/docker
