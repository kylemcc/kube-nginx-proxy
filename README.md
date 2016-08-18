# kube-nginx-proxy
![latest 0.1.0](https://img.shields.io/badge/latest-0.1.0-green.svg?style=flat)
![nginx 1.9.15](https://img.shields.io/badge/nginx-1.9.15-brightgreen.svg?style=flat)
![License BSD](https://img.shields.io/badge/license-BSD-red.svg?style=flat)
[![](https://img.shields.io/docker/stars/kylemcc/kube-nginx-proxy.svg?style=flat)](https://hub.docker.com/r/kylemcc/kube-nginx-proxy 'DockerHub')
[![](https://img.shields.io/docker/pulls/kylemcc/kube-nginx-proxy.svg?style=flat)](https://hub.docker.com/r/kylemcc/kube-nginx-proxy 'DockerHub')

`kube-nginx-proxy` is a Docker container running nginx and [kube-gen][1]. `kube-gen` watches for events on the Kubernetes API and generates nginx server blocks and reverse proxy configurations for Kubernetes Services and Pods as they are started and stopped.

## Usage

The recommended way to run `kube-nginx-proxy` is as a [Daemon Set][2] in your cluster. You may choose to run kube-nginx-proxy on all nodes, or on a subset of nodes in your cluster. A sample Daemon Set spec appears below (as well as [here][3]):

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: "kube-nginx-proxy"
  labels:
    app: "kube-nginx-proxy"
    version: "0.1.0"
  namespace: "dev"
  annotations:
    description: "nginx reverse proxy for services and pods powered by annotations"
spec:
  template:
    metadata:
      labels:
        app: "kube-nginx-proxy"
    spec:
      hostNetwork: true
      # use a nodeSelector to control where pods are scheduled
      # e.g., specify a hostname to run on a single host, or a label to run on a specific group of hosts
      #nodeSelector:
      #  kubernetes.io/hostname: <host>
      #  <label_name>: <label_value>
      containers:
        -
          name: "kube-nginx-proxy"
          image: "kylemcc/kube-nginx-proxy:0.1.0"
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
          ports:
            -
              containerPort: 80
              hostPort: 80
            -
              containerPort: 443
              hostPort: 443
          imagePullPolicy: "Always"
          securityContext:
            privileged: true
      restartPolicy: "Always"
      terminationGracePeriodSeconds: 30
```

[1]: https://github.com/kylemcc/kube-gen
[2]: http://kubernetes.io/docs/admin/daemons/
[3]: https://github.com/kylemcc/kube-nginx-proxy/blob/master/kube-nginx-proxy-daemonset.yaml
