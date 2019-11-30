FROM golang:1 as builder

WORKDIR /go/src/bosh-blobs-upgrader
ADD go.mod go.sum /go/src/bosh-blobs-upgrader/
RUN go mod download
ADD . /go/src/bosh-blobs-upgrader
RUN go build -o /go/bin/bosh-blobs-upgrader

FROM alpine:latest
COPY --from=builder /go/bin/bosh-blobs-upgrader /

RUN apk update && \
    apk --no-cache add \
        bash \
        coreutils \
        curl \
        git \
        jq

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# ENTRYPOINT ["./bosh-blobs-upgrader"]

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]