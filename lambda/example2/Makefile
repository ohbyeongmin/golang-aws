.PHONY: clean build test

build: 
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/main src/sample.go
	cp -r src/config bin/

test:
	aws lambda invoke --region=ap-northeast-2 --function-name=helloGo response.json

clean:
	terraform destroy
	rm -rf terraform.tfstate terraform.tfstate.backup golang-func.zip response.json bin



