#!/bin/bash

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce 
systemctl enable docker
systemctl start docker # 这里会卡一会，等待 docker 启动

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubectl kubelet kubeadm

# 清理残留数据
kubeadm reset -f

if [ "$1" ]; then
  # 加入其他集群中，并作为工作节点，将 `kubeadm join xxxx` 的命令作为第一个参数传进来
  $1
else
  # 初始化新集群，并作为主节点
  kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

exit 0
