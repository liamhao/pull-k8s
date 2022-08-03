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


# 一键卸载
- 授权 `uninstall.sh` 文件 `777` 执行权限：`chmod 777 uninstall.sh`
- 执行卸载：`./uninstall.sh`(卸载时会删除已下载的镜像)


### 海外镜像问题
还在因为部署 `Kubernetes` 时，无法拉取 `k8s.gcr.io/***` 镜像而头疼吗？
记得在初始化 K8S 时，加上 `--image-repository` 参数，并指定阿里云的镜像仓库，就 OK 了。

```sh
$ kubeadm init --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```

> 如果加上`--image-repository`参数以后，依然报错的话，可能是你的DNS解析有问题，需要在`/etc/hosts`中加入以下解析：
> 
> ```
> 47.95.181.38    registry.cn-beijing.aliyuncs.com
> 47.97.242.12    dockerauth.cn-hangzhou.aliyuncs.com
> ```

# 其他错误解决

### 错误：failed to parse kubelet flag: unknown flag: --network-plugin
自 1.24.0 以后，kubernetes 将此参数进行了删除，需要编辑 `/etc/kubernetes/kubelet.conf` 文件，将其中的 `--network-plugin` 参数去掉。还需要将容器管理从 `docker` 改为 `containerd`
```sh
$ mv /etc/containerd/config.toml /etc/containerd/config.toml.bak
$ containerd config default > /etc/containerd/config.toml
$ echo """
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
""" > /etc/crictl.yaml
```

### 错误：/proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
```sh
$ echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
$ echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
```

### 错误：this version of kubeadm only supports deploying clusters with the control plane version >= 1.23.0. Current version: v1.21.14
执行 kubeadm join 的时候，从节点的 kubeadm 版本不能高于主节点，需要把从节点的 kubeadm 进行降版本操作
