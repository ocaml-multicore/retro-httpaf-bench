FROM golang:1.25.0-alpine
WORKDIR /src

RUN apk add --no-cache bash
ENV CGO_ENABLED=0
COPY . /src
RUN go build -o nethttp-go.exe httpserv.go
