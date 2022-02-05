FROM golang:1.17.6-alpine3.15
RUN apk add --no-cache bash
WORKDIR /src
ENV CGO_ENABLED=0
COPY . /src
RUN go build -o nethttp-go.exe httpserv.go
