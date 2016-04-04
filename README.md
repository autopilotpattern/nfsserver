# nfsserver in Docker

A Dockerized version of [sdc-nfs](https://github.com/joyent/sdc-nfs), an NFS v3 server implementation in Node.js.

Example usage:

Start the project and `docker exec` into the "client" container:

```bash
# start the project
docker-compose -f local-compose.yml up -d

# put a test file in the NFS server
docker exec -it nfsserver_nfs_1 touch "/exports/$(date)"

# get a shell in the test client
docker exec -it nfsserver_client_1 bash
```
Inside the "client" container:

```bash
# get the nfs package for Ubuntu
apt-get update && apt-get install -y nfs-common

# make the directory on which we'll mount the NFS volume
mkdir /nfs

# mount the remote NFS volume
mount -t nfs -v -o nolock,vers=3 nfs:/exports /nfs

# list the contents of the NFS volume
ls -al /nfs
```

The server and client containers need `privileged`, though I'm hoping we can find a way to avoid that.