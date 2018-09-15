# SQS Example

## Description

Example app that uses the worker pattern to pull from an SQS queue.

## Usage

You should already have the aws cli installed as well as have terraform installed.

```shell
# Spin up required infrastructure
cd infra
terraform init
terraform apply

# Run worker
go run main.go

# Send message to topic
aws sns publish --message "mobiles chirpin" --topic-arn "{sns_topic_arn}"
```

## TODO

- [x] Update README

## License

[LICENSE](./LICENSE)
