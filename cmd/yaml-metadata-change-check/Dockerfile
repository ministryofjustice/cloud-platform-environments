FROM golang:1.23-alpine

ENV \
    CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /go/bin

COPY go.mod /go/bin
COPY go.sum /go/bin
RUN go mod download
COPY . /go/bin

RUN go build -ldflags "-s -w" .

CMD ["yaml-metadata-change-check"]