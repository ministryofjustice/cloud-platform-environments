FROM debian:bookworm-slim

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY main.go validate-annotations.go ./

RUN go build -o validate-annotations

ENTRYPOINT [ "./validate-annotations" ]