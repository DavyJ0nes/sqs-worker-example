package aws

import (
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

const awsRegion = "eu-west-1"

type SQSWorker struct {
	Name   string
	URL    *string
	Client *sqs.SQS
}

func NewSQSWorker(name string) *SQSWorker {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion)},
	)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			fmt.Println("Problem initialising client:", aerr)
			return &SQSWorker{}
		}
	}

	client := sqs.New(sess)

	url, _ := client.GetQueueUrl(&sqs.GetQueueUrlInput{
		QueueName: aws.String(name),
	})

	return &SQSWorker{
		Name:   name,
		Client: client,
		URL:    url.QueueUrl,
	}
}

func (worker *SQSWorker) Run() {
	msgChan := make(chan string)
	go worker.getMessage(msgChan)

	for msg := range msgChan {
		fmt.Println("-- GOT MESSAGE: ", msg)
	}
}

func (worker *SQSWorker) getMessage(ch chan string) {
	// Receive a message from the SQS queue with long polling enabled.
	for {
		result, err := worker.Client.ReceiveMessage(&sqs.ReceiveMessageInput{
			QueueUrl: worker.URL,
			AttributeNames: aws.StringSlice([]string{
				"SentTimestamp",
			}),
			MaxNumberOfMessages: aws.Int64(1),
			MessageAttributeNames: aws.StringSlice([]string{
				"All",
			}),
			WaitTimeSeconds: aws.Int64(15),
		})

		if err != nil {
			fmt.Printf("Unable to receive message from queue %q, %v.", worker.Name, err)
		}

		for _, msg := range result.Messages {
			log.Println("sending message:", *msg.Body)
			ch <- *msg.Body
			worker.deleteMessage(msg)
		}
	}
}

func (worker *SQSWorker) deleteMessage(msg *sqs.Message) {
	_, err := worker.Client.DeleteMessage(&sqs.DeleteMessageInput{
		QueueUrl:      worker.URL,
		ReceiptHandle: msg.ReceiptHandle,
	})

	if err != nil {
		log.Fatal(err)
	}

	log.Println("deleted message:", *msg.Body)
}
