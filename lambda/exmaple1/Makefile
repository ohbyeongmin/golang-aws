.PHONY: clean build test

build: 
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/main src/handler.go

test:
	aws lambda invoke --region=ap-northeast-2 --function-name=helloGo response.json

clean:
	terraform destroy
	rm -f terraform.tfstate terraform.tfstate.backup golang-func.zip response.json



