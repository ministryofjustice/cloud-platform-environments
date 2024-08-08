FROM golang:1.19 as builder

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o main .

CMD [ "./main" ]