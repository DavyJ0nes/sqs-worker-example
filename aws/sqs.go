package aws

import "github.com/aws/aws-sdk-go/service/sqs"

type SQSWorker struct {
	URL string
}

func NewSQSWorker() *SQSWorker {
	return &SQSWorker
}

func (worker *SQSWorker) Run() {
}
