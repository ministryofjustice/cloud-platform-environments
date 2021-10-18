FROM golang:1.17

WORKDIR /go/src/app
COPY . .

RUN go get -d -v -u ./...
RUN go build .

CMD ["check-ingress"]
