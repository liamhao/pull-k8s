# 拉取外网 Kubernetes 镜像

还在因为部署 `Kubernetes` 时，无法拉取 `k8s.gcr.io/***` 镜像而头疼吗？

记得在初始化 K8S 时，加上 `--image-repository` 参数，并指定阿里云的镜像仓库，就 OK 了。

```shell
kubeadm init --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```
