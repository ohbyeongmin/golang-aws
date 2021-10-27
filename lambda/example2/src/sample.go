package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/spf13/viper"
)

type Test struct {
	Test string `yaml:"test" json:"test"`
}

var testMessage Test

func init() {
	configViper := viper.New()
	configViper.SetConfigName("config")
	configViper.SetConfigType("yaml")
	configViper.AddConfigPath("config")

	err := configViper.ReadInConfig()
	if err != nil {
		panic(err)
	}
	configViper.Unmarshal(&testMessage)
}

func LambdaHandler() (Test, error) {
	return testMessage, nil
}

func main() {
	lambda.Start(LambdaHandler)
}
