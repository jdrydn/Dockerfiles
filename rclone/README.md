# rclone

- A Docker container to execute [`rclone`](https://rclone.org) commands.
- Designed to be dropped into an ECS Fargate scheduled CRON task, passing all configuration through IAM roles & environment variables.
- Single-process execution, and the container terminates when finished.

```sh
$ docker pull jdrydn/rclone:latest
$ docker run --rm jdrydn/rclone:latest \
  --config rclone.conf sync one:// two://
```

## Configuration

Pass a preconfigured `rclone.conf` file to this container and execute your rclone command. There are a few ways you can get your config file into this container:

- Mount a volume to the container during runtime:

```sh
$ docker run --rm -v rclone.conf:rclone.conf:ro jdrydn/rclone:latest \
  --config rclone.conf sync one:// two://
```

- Use this image as the basis for your own, where you can copy your config file into the image, like so:

```dockerfile
FROM jdrydn/rclone:latest
COPY rclone.conf .
```

- Finally, since this was designed to run on AWS, you can provide an `S3_CONFIG` environment variable as an S3 path to your config file, which will be fetched at runtime:

```sh
$ docker run --rm -e S3_CONFIG=s3://secure-bucket/rclone.conf jdrydn/rclone:latest \
  --config rclone.conf sync one:// two://
```

## Use Cases

- Sync two network drives repeatedly, using cloud-native tools like [ECS Scheduled Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html) to avoid the requirement for running a physical server.
- Sync a local drive to a remote backup, on a Docker-focused Container OS such as [CoreOS](https://coreos.com/) or [RancherOS](https://rancher.com/rancher-os/).
