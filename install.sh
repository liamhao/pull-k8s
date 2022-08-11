#!/bin/bash

# 将本机 IP 和主机名的映射关系追加到本地的域名解析文件中
# echo '\nhaosijia\t192.168.0.123' >> /etc/hosts

# 关闭 Selinux，使 SELINUX=disabled
# vim /etc/selinux/config

# 关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

yum install yum-config-manager -y
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce

# 修改docker的监控方式
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://m5r600f9.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload
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

# 查看可用的版本
# yum search kubeadm --showduplicates
yum install -y kubectl kubelet kubeadm

# 清理残留数据
rm -f /etc/cni/net.d/*flannel*
rm -rf /run/flannel
kubeadm reset -f

if [ "$1" ]; then
  # 加入其他集群中，并作为工作节点，将 `kubeadm join xxxx` 的命令作为第一个参数传进来
  $1
  # 记得需要将主节点的 $HOME/.kube/config 复制到工作节点的 $HOME/.kube/config 下
  # scp -P 1111 $HOME/.kube/config root@192.168.0.107:$HOME/.kube/config
else
  # 初始化新集群，并作为主节点
  kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
  cp /etc/kubernetes/admin.conf $HOME/.kube/config
  # 网络管理插件
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  # 解决 failed to set bridge addr: "cni0" already has an IP address different from 10.244.1.1/24 的问题
  # ifconfig cni0 down
  # ip link delete cni0
fi

exit 0
