# github-to-S3

- A Docker container to dump GitHub repo tarballs directly to S3.
- Wraps around [`rclone/rclone`](https://hub.docker.com/r/rclone/rclone) to support backing up multiple repos in series.
- Designed to be dropped into an ECS Fargate scheduled CRON task, passing all configuration through IAM roles & environment variables.
- Single-process execution, and the container terminates when finished.

```sh
$ docker pull jdrydn/github-to-s3:latest
$ docker run \
  -e GITHUB_TOKEN=your-github-token \
  -e S3_BUCKET=project-backups \
  jdrydn/github-to-s3:latest \
  jdrydn/Dockerfiles jdrydn/yoem
ACTION: Downloading jdrydn/Dockerfiles to s3:project-backups/20191012T131547Z-jdrydn-Dockerfiles.tar.gz
ACTION: Downloading jdrydn/yoem to s3:project-backups/20191012T131547Z-jdrydn-yoem.tar.gz
SUCCESS!
```

- You will need to [create a personal access token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) to reach private repositories with this image. If you're concerned about using your personal access token with an organisation, take a look at [machine users](https://developer.github.com/v3/guides/managing-deploy-keys/#machine-users).

## Configuration

To configure this script or `rclone`, pass environment variables at runtime:

| Variable | Default | Description |
| ---- | ---- | ---- |
| `GITHUB_TOKEN` || Optional, but required if you want to fetch a private repo |
| `S3_BUCKET` || **Required,** specify the destination S3 bucket to save the backup to |
| `S3_PREFIX` | (none) | Optionally specify the destination S3 prefix to save the backup to |
| `S3_FILENAME` | `%Y%m%dT%H%M%SZ` | Optionally specify the file prefix for the S3 file, using `date` |

Pass a list of all the repositories you want to be backed up to the Docker CMD. Files will be named `$S3_PREFIX$S3_FILENAME-$REPO.tar.gz`.

You can configure other variables too, such as the AWS region, using `RCLONE_CONFIG_S3_REGION` [and other env vars](https://rclone.org/docs/#environment-variables).

You could even use this image to backup GitHub repositories to an S3-compatible source, such as [DigitalOcean](https://www.digitalocean.com/products/spaces/) or [Minio](https://min.io/), by using the `RCLONE_CONFIG_S3_` variables to set relevant endpoints etc.

## Examples

### Manually

```sh
$ docker run --rm \
  --env-file ./backup.env \
  jdrydn/github-to-s3:latest
  jdrydn/yoem
$ docker run --rm \
  -e GITHUB_TOKEN=your-github-token \
  -e S3_BUCKET=project-backups \
  jdrydn/github-to-s3:latest \
  jdrydn/yoem
```

### ECS Scheduled Task

- Head over to **ECS** and [create a new task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html).
  - Select a **Task Role** that has `S3::putObject` permissions to your target bucket.
  - Add a container & set the **Image** field to the [latest tag](https://hub.docker.com/r/jdrydn/github-to-s3) or any of the versions [listed here](https://hub.docker.com/r/jdrydn/github-to-s3/tags): `jdrydn/github-to-s3:latest`
  - Under **Environment Variables**, enter your configuration following the variables above. Here you can use [SSM](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) values, so you could keep the `GITHUB_TOKEN` values in sync with your application, or similar.
- Next, head over to the [Scheduled Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html) in your cluster & create a new scheduled task. Enter [a CRON expression](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) to describe how often you want this to run, select the task definition you made earlier, and hit create.

#### Manually start a scheduled task

```sh
$ aws ecs run-task \
  --cluster default \
  --task-definition database-backup \
  --launch-type FARGATE \
  --network-configuration 'awsvpcConfiguration={subnets=[A,B,C],securityGroups=[D],assignPublicIp=ENABLED}'
```

- Useful for debugging issues with the scheduled task.
- Remember to put in relevant values for `A`,`B`,`C` & `D`.

## Development

```sh
$ docker build -t jdrydn/github-to-s3:dev .
$ cat << EOF >> .env
GITHUB_TOKEN=your-github-token
S3_BUCKET=backup-bucket
S3_PREFIX=codebase-backups-dev/
EOF
$ docker run --rm -it --network=host \
  -v ~/.aws/credentials:/root/.aws/credentials:ro \
  --env-file ./.env \
  jdrydn/github-to-s3:dev \
  jdrydn/Dockerfiles
```

## With Thanks

- [`rclone/rclone`](https://github.com/rclone/rclone) & [@ncw](https://github.com/ncw).
