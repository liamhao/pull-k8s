#!/bin/bash

k8sReg="k8s.gcr.io"
myReg="registry.cn-beijing.aliyuncs.com/haosijia"

for i in `kubeadm config images list`; do

  imageNameWithVersion=${i#$k8sReg/}

  imageName=${imageNameWithVersion%\:*}
  imageVersion=${imageNameWithVersion#*:}

  if [ $imageName = "coredns/coredns" ]; then
    docker pull $myReg/coredns:$imageVersion
    docker tag $myReg/coredns:$imageVersion $k8sReg/$imageNameWithVersion
    docker rmi $myReg/coredns:$imageVersion
  else
    docker pull $myReg/$imageNameWithVersion
    docker tag $myReg/$imageNameWithVersion $k8sReg/$imageNameWithVersion
    docker rmi $myReg/$imageNameWithVersion
  fi

done;
