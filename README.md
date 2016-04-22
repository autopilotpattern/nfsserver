# Autopilot Pattern NFS server

This repo Dockerizes [sdc-nfs](https://github.com/joyent/sdc-nfs), an NFS v3 server implementation in Node.js. This is intended to allow use NFS in projects without requiring kernel NFS support or privileged access, but that is unfortunately not true. 

## This is not recommended for production use

Server and client containers need `privileged` on Linux hosts (though not on Triton, which supports this securely). This may not be a solvable problem. Docker volume drivers are probably the best recommended work around. On Triton, [RFD26 will provide network shared filesystems](https://github.com/joyent/rfd/blob/master/rfd/0026/README.md) to Docker containers using Docker volume syntax.

For now, consider this an experiment.

### Example usage

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
1. Install the [Docker Toolbox](https://docs.docker.com/installation/mac/) (including `docker` and `docker-compose`) on your laptop or other environment, as well as the [Joyent Triton CLI](https://www.joyent.com/blog/introducing-the-triton-command-line-tool) (`triton` replaces our old `sdc-*` CLI tools).
1. [Configure Docker and Docker Compose for use with Joyent.](https://docs.joyent.com/public-cloud/api-access/docker)

Check that everything is configured correctly by running `./setup.sh`. This will check that your environment is setup correctly and will create an `_env` file that includes injecting an environment variable for the Consul hostname into the NFSServer container so we can take advantage of [Triton Container Name Service (CNS)](https://www.joyent.com/blog/introducing-triton-container-name-service).

Start the NFS server:

```bash
docker-compose -p nfsserver up -d
```

The NFS server will register with the Consul server named in the `_env` file. You can see its status there in the Consul web UI. On a Mac, you can open your browser to that with the following command:

```bash
open "http://$(triton ip nfsserver_consul_1):8500/ui"
```

Client containers should check Consul for the location of the NFSserver instance to mount. See usage examples in [Autopilot Pattern WordPress](https://github.com/autopilotpattern/wordpress) for more detail.

It is not recommended that users scale the `nfsserver` service, as the service does not cluster, and each instance is independent from the others. Scaling will lead to partitions.

### Testing

Start the service as described above, then...

```bash
# put a test file in the NFS server
docker exec -it nfsserver_nfsserver_1 touch "/exports/$(date)"

# start a container as a test client
docker run --rm -it --privileged --link nfsserver_nfsserver_1:nfs ubuntu bash

# get the nfs package for Ubuntu
apt-get update && apt-get install -y nfs-common

# make the directory on which we'll mount the NFS volume
mkdir /nfs

# mount the remote NFS volume
mount -t nfs -v -o nolock,vers=3 nfs:/exports /nfs

# list the contents of the NFS volume
ls -al /nfs
```

### Hacking

This Docker image automates operations using [ContainerPilot](https://www.joyent.com/containerpilot). See both the Dockerfile and ContainerPilot config for more details of the implementation. A walkthrough of how to build your own applications using the [Autopilot Pattern](http://autopilotpattern.io/) can be found at [autopilotpattern.io/example](http://autopilotpattern.io/example).
