ARG ALPINE_TAG=3.19
ARG GO_TAG=1.22-alpine3.19

FROM golang:${GO_TAG} AS builder

WORKDIR /app

COPY go.mod .
COPY go.sum .
COPY main.go .

RUN go get ./...
RUN go build -o main ./...


FROM alpine:${ALPINE_TAG}

LABEL org.opencontainers.image.source=https://github.com/chukmunnlee/go-fortune

WORKDIR /app

RUN apk update && apk --no-cache add curl

COPY --from=builder /app/main main

COPY fortune.txt .
COPY static static
COPY views views

ENV PORT=3000 GIN_MODE=release

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
	CMD curl -s http://localhost:${PORT}/healthz || exit 1

ENTRYPOINT [ "./main" ]

CMD [ "" ]
