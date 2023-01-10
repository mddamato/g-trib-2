FROM registry1.dso.mil/ironbank/google/golang/golang-1.19:latest as builder

COPY ./runforever.go /go/src/runforever/runforever.go
COPY ./go.mod /go/src/runforever/go.mod
WORKDIR /go/src/runforever
USER 0
RUN GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o ./runforever
WORKDIR /workdir
RUN yum install -y unzip && \
    curl -LO https://github.com/mddamato/g-trib-2/archive/refs/heads/main.zip && \
    unzip main.zip && \
    cp -R g-trib-2-main/* . && \
    rm -rf g-trib-2-main && \
    rm -f main.zip
FROM scratch
COPY --from=builder /go/src/runforever/runforever /runforever
WORKDIR /workdir
COPY --from=builder /workdir /workdir
ENTRYPOINT ["/runforever"]