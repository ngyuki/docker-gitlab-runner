FROM golang:alpine

RUN apk add --no-cache --virtual .builddeps git &&\
    go get github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login &&\
    mv bin/docker-credential-ecr-login /usr/bin/ &&\
    rm -fr /go/src/* &&\
    go clean -cache &&\
    apk del .builddeps

FROM gitlab/gitlab-runner:alpine

COPY --from=0 /usr/bin/docker-credential-ecr-login /usr/bin/docker-credential-ecr-login

RUN mkdir -p /root/.docker/ &&\
    echo '{ "credsStore": "ecr-login" }' > config.json
