package main

import "github.com/davyj0nes/sqs-example/aws"

func main() {
	worker := aws.NewSQSWorker("example-queue")
	worker.Run()
}
