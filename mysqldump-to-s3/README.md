# mysqldump-to-s3

- A Docker container to dump MySQL data backups directly into S3.
- Pipes `mysqldump` into `aws-cli` to avoid any storage restrictions you may have.
- Designed to be dropped into an ECS Fargate scheduled CRON task, passing all configuration through IAM roles & environment variables.
- Uploads files as gzip'd SQL to keep storage use low.
- Single-process execution, and the container terminates when finished.

```sh
$ docker pull jdrydn/mysqldump-to-s3:latest
# OR: docker pull ghcr.io/someimportantcompany/mysqldump-to-s3:latest
# OR: docker pull public.ecr.aws/someimportantcompany/mysqldump-to-s3:latest
$ docker run \
  -e S3_BUCKET=project-backups \
  -e MYSQL_HOST=project.3927e3a82872.us-east-1.rds.amazonaws.com \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_DATABASE=PROJECT \
  jdrydn/mysqldump-to-s3:latest
ACTION: Creating individual dump of PROJECT from project.3927e3a82872.us-east-1.rds.amazonaws.com to s3://project-backups/20190810T050709Z.PROJECT.sql.gz
SUCCESS!
```

## Configuration

To configure `mysqldump` or `aws s3`, pass environment variables at runtime:

| Variable | Default | Description |
| ---- | ---- | ---- |
| `S3_BUCKET` || **Required,** specify the destination S3 bucket to save the backup to |
| `S3_PREFIX` | (none) | Optionally specify the destination S3 prefix to save the backup to |
| `S3_FILENAME` | `%Y%m%dT%H%M%SZ` | Optionally specify the file prefix for the S3 file, using `date` |
| `MYSQL_HOST` | `localhost` | Specify the MySQL host |
| `MYSQL_USER` | `mysql` | Specify the MySQL username |
| `MYSQL_PASSWORD` | (none) | Optionally specify a MySQL password |
| `MYSQL_DATABASE` | (none) | Optionally specify a MySQL database, otherwise they will all be dumped |
| `MYSQLDUMP_OPTIONS` | `--single-transaction --compress --compact` | Specify options for `mysqldump` |

To configure `aws-cli` in general, [see the AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). If you're using ECS you could attach an IAM role to the task definition, or you can pass `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` environment variables too.

Omitting `MYSQL_DATABASE` will cause all databases on the host to be dumped to S3. Files will be named `$S3_PREFIX$S3_FILENAME.$DB_NAME.sql.gz`.

## Examples

### Manually

```sh
$ docker run --rm --env-file ./backup.env jdrydn/mysqldump-to-s3:latest
$ docker run --rm \
  -e MYSQL_HOST=project.3927e3a82872.us-east-1.rds.amazonaws.com
  -e MYSQL_USER=root -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=PROJECT \
  -e S3_BUCKET=project-backups
```

### ECS Scheduled Task

- Head over to **ECS** and [create a new task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html).
  - Select a **Task Role** that has `S3::putObject` permissions to your target bucket.
  - Add a container & set the **Image** field to the [latest tag](https://hub.docker.com/r/jdrydn/mysqldump-to-s3) or any of the versions [listed here](https://hub.docker.com/r/jdrydn/mysqldump-to-s3/tags): `jdrydn/mysqldump-to-s3:latest`
  - Under **Environment Variables**, enter your configuration following the variables above. Here you can use [SSM](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) values, so you could keep the `MYSQL_*` values in sync with your application, or similar.
- Next, head over to the [Scheduled Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html) in your cluster & create a new scheduled task. Enter [a CRON expression](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) to describe how often you want this to run, select the task definition you made earlier, and hit create.

#### Manually start a scheduled task

```sh
$ aws ecs run-task \
  --cluster default \
  --task-definition database-backup \
  --network-configuration 'awsvpcConfiguration={subnets=[A,B,C],securityGroups=[D],assignPublicIp=ENABLED}' \
  --launch-type FARGATE
```

- Useful for debugging issues with the scheduled task.
- Remember to put in relevant values for `A`,`B`,`C` & `D`.

### Restoring your database using output from this

- `aws s3 cp` to download the file to your local machine
- `gunzip` to decompress the file
- Import into `mysql`

```sh
# Unpipe these commands apart for large backups
$ aws s3 cp s3://project-backups/20190810T050709Z.PROJECT.sql.gz | gunzip | mysql PROJECT
# ☕️ Now might be a good time to grab a coffee?
```

## Development

```sh
$ docker build -t jdrydn/mysqldump-to-s3:dev .
$ cat << EOF >> backup.env
MYSQL_HOST=localhost
MYSQL_USER=user
MYSQL_PASSWORD=password
S3_BUCKET=test-backups
EOF
$ docker run --rm -it --network=host \
  -v ~/.aws/credentials:/root/.aws/credentials:ro \
  --env-file ./local.env \
  jdrydn/mysqldump-to-s3:dev
```

## With Thanks

- Loosely forked from [`schickling/mysql-backup-s3`](https://hub.docker.com/r/schickling/mysql-backup-s3) but adapted to use a pipe to avoid storage restrictions on Fargate.
