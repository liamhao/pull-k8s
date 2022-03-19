#!/bin/bash

k8sReg="k8s.gcr.io"

for i in `kubeadm config images list`; do

  # 截取最新的版本信息
  imageNameWithVersion=${i#$k8sReg/}
  imageName=${imageNameWithVersion%\:*}
  imageVersion=${imageNameWithVersion#*:}

  # coredns 镜像特殊处理
  if [ $imageName = "coredns/coredns" ]; then
    imageName="coredns"
  fi

  # 克隆仓库
  if [ ! -d $imageName ]; then
    git clone git@github.com:liamhao/$imageName.git
  fi

  # 进入目录
  cd $imageName

  # 设置用户
  git config --global user.email w736611944@gmail.com
  git config --global user.name liamhao

  # 修改 Dockerfile
  text=`cat Dockerfile`
  newText=${text%\:*}:$imageVersion
  echo $newText
  echo $newText > Dockerfile

  # 打 tag, release-v 开头的 tag 会自动触发阿里云的构建
  tag="release-v$imageVersion"
  git add .
  git commit -m 'update new version'
  git tag $tag
  git push origin $tag

  # 返回上一级目录
  cd ..

done;
