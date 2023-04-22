# rclone

- A Docker container to execute [`rclone`](https://rclone.org) commands.
- Designed to be dropped into an ECS Fargate scheduled CRON task, passing all configuration through IAM roles & environment variables.
- Single-process execution, and the container terminates when finished.

```sh
$ docker pull jdrydn/rclone:latest
# OR: docker pull ghcr.io/someimportantcompany/rclone:latest
# OR: docker pull public.ecr.aws/someimportantcompany/rclone:latest
$ docker run --rm jdrydn/rclone:latest \
  rclone --config rclone.conf sync one:// two://
```

## Configuration

Pass a preconfigured `rclone.conf` file to this container and execute your rclone command. There are a few ways you can get your config file into this container:

- Mount a volume to the container during runtime:

```sh
$ docker run --rm \
  -v rclone.conf:rclone.conf:ro \
  jdrydn/rclone:latest \
  rclone --config rclone.conf sync one:// two://
```

- Use this image as the basis for your own, where you can copy your config file into the image, like so:

```dockerfile
FROM jdrydn/rclone:latest
COPY rclone.conf /root/.config/rclone/rclone.conf
```
```sh
$ docker build -t my/rclone:latest .
$ docker run --rm my/rclone:latest rclone sync one:// two://
```

- Finally, [rclone can be configured entirely using environment variables](https://rclone.org/docs/#environment-variables), like these examples:

```sh
$ docker run --rm \
  -e RCLONE_CONFIG_ONE_TYPE=s3 \
  -e RCLONE_CONFIG_ONE_ENV_AUTH=true \
  -e RCLONE_CONFIG_ONE_ACL=private \
  -e RCLONE_CONFIG_TWO_TYPE=b2 \
  -e RCLONE_CONFIG_TWO_ACCOUNT=ABC \
  -e RCLONE_CONFIG_TWO_KEY=XYZ \
  -e RCLONE_CONFIG_TWO_HARD_DELETE=true \
  jdrydn/rclone:latest rclone sync one:// two://
```
```sh
$ cat << EOF >> rclone.env
RCLONE_CONFIG_ONE_TYPE = s3
RCLONE_CONFIG_ONE_ENV_AUTH = true
RCLONE_CONFIG_ONE_ACL = private
RCLONE_CONFIG_TWO_TYPE = b2
RCLONE_CONFIG_TWO_ACCOUNT = ABC
RCLONE_CONFIG_TWO_KEY = XYZ
RCLONE_CONFIG_TWO_HARD_DELETE = true
EOF
$ docker run --rm --env-file rclone.env \
  jdrydn/rclone:latest rclone sync one:// two://
```

## Development

```sh
$ docker build -t jdrydn/rclone:dev .
$ docker run --rm \
  -v ~/.config/rclone/rclone.conf:/root/.config/rclone/rclone.conf:ro \
  jdrydn/rclone:dev \
  rclone config
```

## Use Cases

- Sync two network drives repeatedly, using cloud-native tools like [ECS Scheduled Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html) to avoid the requirement for running a physical server.
- Sync a local drive to a remote backup, on a Docker-focused Container OS such as [CoreOS](https://coreos.com/) or [RancherOS](https://rancher.com/rancher-os/).
