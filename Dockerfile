# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} golang:1.18-alpine3.15 AS builder

RUN apk add git

WORKDIR /go/src/app
COPY . .

ARG TARGETOS TARGETARCH TARGETVARIANT

ENV CGO_ENABLED=0
RUN go get \
    && go mod download \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT#"v"} go build -a -o rtsp-to-web

FROM alpine:3.15

WORKDIR /app

COPY --from=builder /go/src/app/rtsp-to-web /app/
COPY --from=builder /go/src/app/web /app/web

RUN mkdir -p /config
COPY --from=builder /go/src/app/config.json /config

ENV GO111MODULE="on"
ENV GIN_MODE="release"

CMD ["./rtsp-to-web", "--config=/config/config.json"]

# az login
# az acr login --name iobtassets
# docker build -t rtsptoweb -f Dockerfile  .
# docker tag rtsptoweb iobtassets.azurecr.io/rtsptoweb:v1.0.0
# docker push iobtassets.azurecr.io/rtsptoweb:v1.0.0
#
# RUN THIS IN UBUNTU - NOT FROM CMD PROMPT
#
# docker run -it  --network host -v /tmss/config.json:/config/config.json --rm --name rtsptoweb rtsptoweb
# docker run -d  --network host -v /tmss/config.json:/config/config.json --rm --name rtsptoweb rtsptoweb
# docker exec -it rtsptoweb bash
