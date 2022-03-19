# 拉取外网 Kubernetes 镜像

还在因为部署 `Kubernetes` 时，无法拉取 `k8s.gcr.io/***` 镜像而头疼吗？

记得在初始化 K8S 时，加上 `--image-repository` 参数，并指定阿里云的镜像仓库，就 OK 了。

```shell
kubeadm init --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```

# 批量修改镜像 `registry.cn-hangzhou.aliyuncs.com/***` 为 `k8s.gcr.io/***`

- 首先，你的机器上必须要安装了 `kubeadm` 程序（检查：`kubeadm version`）
- 克隆仓库：`clone https://github.com/liamhao/pull-k8s.git`
- 进入此项目，授权 `pull.sh` 文件 `777` 执行权限：`chmod 777 pull.sh`
- 执行拉取：`./pull.sh`
- 验证：`docker images`
![image](https://user-images.githubusercontent.com/31812811/159112881-30c06314-f64f-4298-8766-f1d0bf60b1aa.png)
