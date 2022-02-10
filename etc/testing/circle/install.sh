#!/bin/bash

set -ex

mkdir -p cached-deps

architecture=""
case $(uname -m) in
    x86_64) architecture="amd64" goreleaserarch="x86_64";;
    aarch64) architecture="arm64" goreleaserarch="arm64";;
    arm64)    architecture="arm64" goreleaserarch="arm64" ;;
esac

# Install deps
sudo apt update -y
sudo apt-get install -y -qq \
  silversearcher-ag \
  python3 \
  python3-pip \
  python3-setuptools \
  pkg-config \
  fuse \
  conntrack \
  pv \
  shellcheck \
  docker-ce-cli

# Install fuse
sudo modprobe fuse
sudo chmod 666 /dev/fuse
sudo cp etc/build/fuse.conf /etc/fuse.conf
sudo chown root:root /etc/fuse.conf

# Install aws CLI (for TLS test)
pip3 install --upgrade --user wheel
pip3 install --upgrade --user awscli s3transfer==0.3.4

# Install kubectl
# To get the latest kubectl version:
# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
if [ ! -f cached-deps/kubectl ] ; then
    KUBECTL_VERSION=v1.19.2
    curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${architecture}/kubectl && \
        chmod +x ./kubectl
        mv ./kubectl cached-deps/kubectl
fi

# Install minikube
# To get the latest minikube version:
# curl https://api.github.com/repos/kubernetes/minikube/releases | jq -r .[].tag_name | sort -V | tail -n1
if [ ! -f cached-deps/minikube ] ; then
    MINIKUBE_VERSION=v1.19.0 # If changed, also do etc/kube/start-minikube.sh
    curl -L -o minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-${architecture} && \
        chmod +x ./minikube
        mv ./minikube cached-deps/minikube
fi

# Install etcdctl
# To get the latest etcd version:
# curl -Ls https://api.github.com/repos/etcd-io/etcd/releases | jq -r .[].tag_name
if [ ! -f cached-deps/etcdctl ] ; then
    ETCD_VERSION=v3.5.1
    curl -L https://storage.googleapis.com/etcd/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${architecture}.tar.gz \
        | tar xzf - --strip-components=1
        mv ./etcdctl cached-deps/etcdctl
fi

# Install helm
if [ ! -f cached-deps/helm ]; then
  HELM_VERSION=3.5.4
  curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${architecture}.tar.gz \
      | tar xzf - linux-${architecture}/helm
      mv ./linux-${architecture}/helm cached-deps/helm
fi

# Install goreleaser 
if [ ! -f cached-deps/goreleaser ]; then
  GORELEASER_VERSION=1.4.1
  curl -L https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_${goreleaserarch}.tar.gz \
      | tar xzf - -C cached-deps goreleaser
fi

# Install jq
if [ ! -f cached-deps/jq ]; then
  JQ_VERSION=1.6
  curl -L https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 > cached-deps/jq
fi

# Update go
sudo rm -rf /usr/local/go
curl -L https://golang.org/dl/go1.17.3.linux-${architecture}.tar.gz | sudo tar xzf - -C /usr/local/

# Install kubeval
if [ ! -f cached-deps/kubeval ]; then
  KUBEVAL_VERSION=v0.16.1
  go install github.com/instrumenta/kubeval@${KUBEVAL_VERSION}
  mv $(which kubeval) cached-deps/kubeval
fi
