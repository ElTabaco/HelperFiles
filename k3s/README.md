# k3s Multimaster node

Build a k3s multimaster node cluster.
In this repo are exampels for images i use for my usecases.

_Everyone can contribute and commit solved bugs is welcome_

## k3s install / update / uninstall

### k3s uninstall

* Uninstall k3s from node:
  * [docs.k3s.io](https://docs.k3s.io/installation/uninstall)
```console
sudo /usr/local/bin/k3s-uninstall.sh
```

## k3s configuration

### Multi CPU Architecture

* Label nodes with CPU Architecture types:
  * [technotim-live](https://technotim-live.translate.goog/posts/multi-arch-k3s-rpi/?_x_tr_sl=en&_x_tr_tl=de&_x_tr_hl=de&_x_tr_pto=sc)
```console
kubectl label nodes mr1 cputype=arm64
# or
kubectl label nodes mr0 cputype=amd64

kubectl describe node nodename
```

## Command helper wiki

* Snippets used frequently to create, run and debug own kubernetes apps

### Node level:

* Clone repository
```console
kubectl get nodes --all-namespaces -o wide
```
### Pod level:

* Get all pods
```console
kubectl get pods --all-namespaces -o wide
kubectl get svc --all-namespaces -o wide

```

* Get pod information
```console
kubectl get pv --all-namespaces -o wide
kubectl get pvc --all-namespaces -o wide

kubectl log <containername>
```

### Container level:

* Enter running container:
  * [kubernetes.io/docs](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/)

```console
kubectl exec -n <NAMESPACE> <POD_NAME> --container <CONTAINER_NAME> -it -- /bin/sh
```

#### get ports
```console
netstat -tulnp
lsof -i -P -n

```


