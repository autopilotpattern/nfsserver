# nfsserver in Docker

A Dockerized version of [sdc-nfs](https://github.com/joyent/sdc-nfs), an NFS v3 server implementation in Node.js.

Example usage:

Start the project and `docker exec` into the "client" container:

```bash
docker-compose -f local-compose.yml up -d
docker exec -it nfsserver_client_1 bash
```
Inside the "client" container:

```bash
apt-get update && apt-get install -y nfs-common
mkdir /nfs
mount -t nfs -v -o nolock,vers=3 nfs:/exports /nfs
```

The server and client containers need `privileged`, though I'm hoping we can find a way to avoid that.