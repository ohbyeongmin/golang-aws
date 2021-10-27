Lambda 는 컨테이너 이미지 및 .zip 파일 아카이브의 두 가지 배포 패키지를 지원합니다.

## macOS 및 Linux에서 .zip 파일 만들기

1. lambda 라이브러리 다운로드

```bash
$go get github.com/aws/aws-lambda-go/lambda
```

2. 실행 파일을 컴파일 합니다.

```bash
GOOS=linux go build main.go
```

3. (선택 사항) main 패키지가 여러 파일로 구성된 경우 다음 go build 명령을 사용하여 패키지를 컴파일합니다.

```bash
GOOS=linux go build main
```

4. (선택 사항) Linux에서 CGO_ENABLED=0 세트를 사용하여 패키지를 컴파일해야 할 수도 있습니다.

```bash
GOOS=linux CGO_ENABLED=0 go build main.go
```

이 명령은 표준 C 라이브러리(libc) 버전에 대해 안정적인 바이너리 패키지를 만듭니다. 이 패키지는 다른 Lambda 및 다른 장치에서 다를 수 있습니다.

5. Lambda는 POSIX 파일 권한을 사용하므로 .zip 파일 아카이브를 만들기 전에 배포 패키지 폴더에 대한 사용 권한을 설정해야 할 수 있습니다.

6. 실행 파일을 .zip 파일로 패키지하여 배포 패키지를 만듭니다.

```bash
zip function.zip main
```

## bulid 방법

```bash
set GOOS=linux
set GOARCH=amd64
set CGO_ENABLED=0

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main main.go
```

## Lambda 함수 호출

```bash
aws lambda invoke --region=ap-northeast-2 --function-name=FUNCNAME response.json
```
