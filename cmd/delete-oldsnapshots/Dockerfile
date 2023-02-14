# syntax=docker/dockerfile:1
FROM golang:1.19-alpine AS builder

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

RUN mkdir app

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY . ./

# Download all the dependencies
RUN go mod download

# Build the Go app
RUN CGO_ENABLED=0 go build -o delete-oldsnapshots . 

RUN chown -R appuser:appgroup /app

# second stage to obtain a very small image
FROM scratch

# copy the ca-certificate.crt from the build stage
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# copy user permissions from builder
COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /app/delete-oldsnapshots /delete-oldsnapshots

USER 1000

EXPOSE 3000

CMD [ "/delete-oldsnapshots" ]