#!/bin/bash

k8sReg="k8s.gcr.io"
aliReg="registry.cn-hangzhou.aliyuncs.com/google_containers"

for i in `kubeadm config images list`; do

  imageNameWithVersion=${i#$k8sReg/}
  imageName=${imageNameWithVersion%\:*}
  imageVersion=${imageNameWithVersion#*:}

  # 特殊处理
  if [ $imageName = "coredns/coredns" ]; then
    imageNameWithVersion="coredns:$imageVersion"
  fi

  docker pull $aliReg/$imageNameWithVersion
  docker tag $aliReg/$imageNameWithVersion $k8sReg/$imageNameWithVersion
  docker rmi $aliReg/$imageNameWithVersion

done;
