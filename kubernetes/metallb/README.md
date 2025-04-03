# k3s Multimaster node

Build a k3s multimaster node cluster.
Install metallb on k3s cluster.

_Everyone can contribute and commit solved bugs is welcome_

## k3s configuration

## Disabling Klipper


Add folofing when install k3s server

```console
...
--disable servicelb
```

## Metallb
https://metallb.universe.tf/installation/
MetalLB installation by manifest section, install into the metallb-system namespace.
