# 一键安装 Kubernetes
- 授权 `install.sh` 文件 `777` 执行权限：`chmod 777 install.sh`

### 作为主节点
- 执行安装：`./install.sh`(启动 docker 时会卡一会，大概 30 秒)

### 作为工作节点
- 将主节点生成的 `kubeadm join xxxxx` 命令作为参数，传递到脚本中，如：`./install.sh 'kubeadm join 192.168.0.123:6443 --token jkkdoo.t6raeul1jeb9zm6n --discovery-token-ca-cert-hash sha256:00f3bc143408748f6d9e964dcc13855ac3d9a1f440b5b218ce01860c1b61659b'`


# 拉取外网 `k8s.gcr.io/***` 镜像

- 首先，你的机器上必须要安装了 `kubeadm` 程序（检查：`kubeadm version`）
- 授权 `pull.sh` 文件 `777` 执行权限：`chmod 777 pull.sh`
- 执行拉取：`./pull.sh`
- 验证：`docker images`
![image](https://user-images.githubusercontent.com/31812811/159112881-30c06314-f64f-4298-8766-f1d0bf60b1aa.png)


### 海外镜像问题

还在因为部署 `Kubernetes` 时，无法拉取 `k8s.gcr.io/***` 镜像而头疼吗？

记得在初始化 K8S 时，加上 `--image-repository` 参数，并指定阿里云的镜像仓库，就 OK 了。

```shell
kubeadm init --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```
