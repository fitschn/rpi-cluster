[TOC]

# Requirements

* Kernel 5.19 or greater - tested with Ubuntu 22.04.3 HWE Kernel 6.2

# Container runtime

## runc vs. crun

We decided to go with `crun` as container runtime, as it had better support for user namespaces,
when we started to develop the containerd deployment. User namespaces required either `runc>=1.2`
or `crun>=1.9`, but the required `runc` version wasn't available as stable release.

`crun` is a fully compatible in-place replacement for `runc` as both follow the official `cri`
specifications.

# User namespaces

There is an [ADR](https://docs.io.ki/doc/0001-user-namespace-with-containerd-yXvhs4FzAC) about user
namespaces and why we want to use it.

To use it within your container manifests, you have to disable `hostUsers`:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    role: nginx
spec:
  hostUsers: false
  containers:
    - name: nginx-userns
      image: nginx
```

# Permissions

`containerd` is configured to use `root` as user and `containerd` as group. This allows us to put
any user into the `containerd` group, who should be able to interact with the container environment
via `crictl`.

`nerdctl` still requires root - have a look at the `nerdctl` limitations for the details.

# CNIs and networking

As we want to use user namespaces for most of our containers, we are forced to also provide some
kind of overlay networking, as it is not allowed to start containers with enabled user namespaces
within the host network (which makes sense).

For now we are using a very basic bridge plugin for the overlay networks. For containers within
the host user namespace, it's still possible to use the host network, if required.

You can expose ports to the outside of the containers by adding `ports` to the container manifest
file. It's important to use type `hostPort`. `hostIP` is optional - if not specified, port will be
opened for all IPs on the host:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    role: nginx
spec:
  hostUsers: false
  containers:
    - name: nginx-userns
      image: nginx
      ports:
        - containerPort: 80
          hostPort: 80
          hostIP: 127.0.0.1
```

Doing this results in iptable rules which route traffic to the pod network. The port itself isn't
exposed in the host namespace. So the command `ss -tlpen` won't show the open ports.

# CLIs

## Crictl limitations

### No classic `run` command

To start new containers with `crictl`, you would have to provide the specification in json format
for pod and container. This is very cumbersom, which is the reason why we also deploy `nerdctl` as
an alternative. `nerdctl` is fully compatible to the docker CLI.

## Nerdctl limitations

### Default runtime environment

nerdctl uses `runc` as default container runtime. Therefore it searches for the `runc` binary
within `$PATH`. For our deployment we are using `crun` as an alternative container runtime, so we
have to override it manually. Unfortunately there is no config parameter we could set and have to
provide the `--runtime` option each time, we use `nerdctl run`.

For ansible tasks there is a global variable you can use, to set the runtime parameter:
* `{{ nerdctl_run_options }}`

Please keep in mind, that this options isn't a global option for nerdctl and is only used for some
subcommands, like `run` or `create`.

### Must be run as root

There is no option to use nerdctl as normal user just by adding the user to the `containerd` group.
It's a known limitation which is already discussed [here](https://github.com/containerd/nerdctl/issues/341)
and [here](https://github.com/containerd/nerdctl/blob/main/docs/faq.md#does-nerdctl-have-an-equivalent-of-sudo-usermod--ag-docker-user-).
