FROM golang:1.17

WORKDIR /go/src/app
COPY . .

RUN go get -v -u ./...
RUN go build .

CMD ["terraform-ns-checker"]
