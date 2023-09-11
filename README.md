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
如果提示`没有那个文件或目录: /proc/sys/net/bridge/bridge-nf-call-iptables`，则需要通过`modprobe br_netfilter`命令来自动加载所需的模块
`net.bridge.bridge-nf-call-iptables=1`这个配置是`flannel`网络必须的，如果没有这个，则会出现集群内无法解析service名称的问题
```sh
$ modprobe br_netfilter
$ echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.conf
$ sysctl -p
```
参考：[K8S集群中某个worker节点上无法通过域名访问服务 ？](https://www.talkwithtrend.com/Article/253337)

### 错误：this version of kubeadm only supports deploying clusters with the control plane version >= 1.23.0. Current version: v1.21.14
执行 kubeadm join 的时候，从节点的 kubeadm 版本不能高于主节点，需要把从节点的 kubeadm 进行降版本操作

# 笔记

## 搭建 Kubernetes 集群

<img src=https://kubernetes.io/images/nav_logo2.svg height=100px/>

- 详情查看 Github 仓库: [liamhao/pull-k8s](https://github.com/liamhao/pull-k8s/blob/main/install.sh)

## 安装 Helm 应用管理系统

<img src=https://helm.sh/img/helm.svg height="100px"/>

- 在 [Github Releases](https://github.com/helm/helm/releases) 页面下载和 k8s master 机器对应的版本二进制文件，解压缩，并将 `helm` 二进制文件复制到 `/usr/local/bin` 目录下
- >helm 的操作需要在 master 节点上执行
```sh
# 先在 k8s 中新建一个名为 kubeapps 的 namespace
kubectl create ns kubeapps

# 在 k8s 中创建 RBAC 管理账号
kubectl create serviceaccount kubeapps-operator -n kubeapps

# 绑定管理账号与角色的关系
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=kubeapps:kubeapps-operator

# 添加 helm 官方 chart 仓库
helm repo add bitnami https://charts.bitnami.com/bitnami

# 安装 kubeapps 应用管理页面 ui
helm install kubeapps --namespace kubeapps bitnami/kubeapps

# 想办法通过设置 Ingress 或使用 kubeapps service NodePort 的服务方式，访问 kubeapps 页面
# 登录时需使用上面创建的 ubeapps-operator 账号的 token，查看 token
kubectl get secret $(kubectl get serviceaccount kubeapps-operator -n kubeapps -o jsonpath='{range .secrets[*]}{.name}{"\n"}{end}' | grep kubeapps-operator-token) -o jsonpath='{.data.token}' -o go-template='{{.data.token | base64decode}}' -n kubeapps && echo
```

## 安装 Harbor 镜像管理系统

<img src=https://goharbor.io/img/logos/harbor-horizontal-color.png height="100px"/>

- 通过上面的 `helm` 部署高可用的 harbor 应用
- 先在 k8s 中新建一个名为 `harbor` 的 namespace
```sh
kubectl create ns harbor
```
- 在 kubeapps 的页面中，先将右上角的 `Current Context` 中的 `Namespace` 改选为 `harbor`，然后点击 `CHANGE CONTEXT`
- 手动添加 harbor chart 仓库，添加仓库时会绑定 namespace，切换 `Namespace` 时，每个仓库只会在当前的 namespace 下出现
```sh
# 命令行中添加不会影响到 kubeapps 页面，所以需要手动在 kubeapps 页面上添加
helm repo add harbor https://helm.goharbor.io
```
- 勾选 `Package Repository` 中的 `harbor`，刷新页面后会出现 harbor 的应用
- 点击应用进入详情，点击右上角的 `DEPLOY`
- 在 `Name` 中输入 `harbor`，下面的 `YAML` 中需配置几个参数
```yaml
expose:
    type: nodePort # harbor 应用以 NodePort 的方式开放访问
    tls:
        enabled: false # 关闭 ssl 证书验证，使用 http 的方式
externalURL: http://192.168.0.166:30002 # 设置开放访问的地址，{任意集群ip}:30002
persistence:
    persistentVolumeClaim:
        registry:
            storageClass: nfs-php # 在 k8s 中预先设置的 StorageClass，下同
        chartmuseum:
            storageClass: nfs-php
        jobservice:
            storageClass: nfs-php
        database:
            storageClass: nfs-php
        redis:
            storageClass: nfs-php
        trivy:
            storageClass: nfs-php
```
- 点击下面的 `DEPLOY`，等待几分钟即可通过 `http://192.168.0.166:30002` 访问，账号和密码都可在上面的 YAML 文件中找到
- >构建新的镜像时，需要将镜像的名称设置为 `192.168.0.166:30002/library/{自定义名称}:{版本}` 才可以推送到 harbor 仓库中
- >推送新的镜像时，需要先通过 `docker login -u {harbor用户名} -p {harbor密码}` 登录后，才能 `docker push {镜像完整名称}` 进行推送
- >拉取新的镜像时，需要将集群内的全部机器的 `/etc/docker/daemon.json` 中加入 `"insecure-registries":["192.168.0.166:30002"]` 配置项，然后 `systemctl restart docker` 重启 docker

## ChartMuseum 管理私有 chart

<img src="https://s2.loli.net/2022/08/05/HiFE5VmaRT6zfys.png" height=100px/></a>
<!-- <img src=https://cdn.learnku.com/uploads/images/202208/02/41543/uWTObKRyzg.png height=100px /> -->
<!-- <img src=https://cdn.learnku.com/uploads/images/202208/02/41543/siORiNSrtk.png height=100px /> -->

- 上面通过 helm 安装的 harbor 应用已经自带了 chartmuseum 系统，可在 harbor 的管理界面找到 `Helm Charts` 页面
- 可参照 [Helm 官方文档](https://helm.sh/zh/docs/helm/helm_create) 创建自定义 chart 模板
- 推送自定义 chart 前需要先安装 [上传插件](https://github.com/chartmuseum/helm-push)
- 还需要为 helm 指明自定义的 harbor 仓库
```sh
# zhufaner 为仓库名称，可自定义，http://192.168.0.166:30002 为 harbor 接口地址，chartrepo/library 为 chart 路径，必填，后面是登录 harbor 的账号和密码
helm repo add zhufaner http://192.168.0.166:30002/chartrepo/library --username admin --password Harbor12345
```
- 推送自定义 chart
```sh
# 进入自定义的 chart 目录
cd mychart

# 执行推送当前的 chart 到名为 zhufaner 的 chartmuseum 仓库
helm cm-push . zhufaner
```
- 可选，为 chart 生成安装文档
- 下载 [helm-docs](https://github.com/norwoodj/helm-docs/releases) 二进制文件，解压缩，将 `helm-docs` 复制到 `/usr/local/bin` 目录下
- 为自定义 chart 生成 README.md 文档，这样，在 kubeapps 中安装应用时，就可以看到安卓说明以及参数定义了
```sh
# 进入自定义的 chart 目录
cd mychart

# 执行生成文档
helm-docs
```

## 安装 Istio 服务网格

<img src="https://s2.loli.net/2022/08/05/zUQYR5Ek38OKtp7.png" height=100px/>

- 下载软件包 `curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.3 TARGET_ARCH=x86_64 sh -`，需要多等一些时间，比较慢，`ISTIO_VERSION` 和 `TARGET_ARCH` 按自己需求调整版本和平台，然后解压缩，将里面的 `bin/istioctl` 复制到 `/usr/local/bin` 目录下
- 执行安装和配置
```sh
# 安装基础组件，默认情况下 istio-ingressgateway 使用的是 LoadBalancer 服务方式，改为 NodePort 方式
istioctl install -y --set values.gateways.istio-ingressgateway.type=NodePort

# 进入解压后的目录
cd istio-1.14.3

# 启用相关的组件 jaeger、kiali、prometheus、grafana
kubectl apply -f samples/addons
# kiali 配置文件默认使用的是 ClusterIP，需要手动改为 NodePort 方式
# 访问 kiali 页面时，端口使用的是 20001 对应的 nodeport

# 配置名称为 default 的 namespace 启用自动注入 sidecar 功能
kubectl label namespace default istio-injection=enabled
# 对于开启自动注入前已经生成的工作负载，需要删除已经启动的 pod
```
