# 拉取外网 Kubernetes 镜像

还在因为部署 `Kubernetes` 时，无法拉取 `k8s.gcr.io/***` 镜像而头疼吗？

### 使用

- 首先，你的机器上必须要安装了 `kubeadm` 程序（检查：`kubeadm version`）
- 克隆仓库：`clone https://github.com/liamhao/pull-k8s.git`
- 进入此项目，授权 `pull.sh` 文件 `777` 执行权限：`chmod 777 pull.sh`
- 执行拉取：`./pull.sh`

### 包含镜像
| 名称 | 版本 |
| :----- | :----: |
| k8s.gcr.io/kube-apiserver | >= v1.23.4 |
| k8s.gcr.io/kube-controller-manager | >= v1.23.4 |
| k8s.gcr.io/kube-scheduler | >= v1.23.4 |
| k8s.gcr.io/kube-proxy | >= v1.23.4 |
| k8s.gcr.io/pause | >= 3.6 |
| k8s.gcr.io/etcd | >= 3.5.1-0 |
| k8s.gcr.io/coredns/coredns | >= v1.8.6 |

### 说明

此脚本中使用的镜像均来自阿里云「容器镜像服务」，是从 `k8s.gcr.io` 同步过来的，与海外镜像保持一致，未对镜像进行任何篡改，可放心使用。
目前同步的镜像版本较少，后续会陆续补充，
