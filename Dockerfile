FROM golang:1.21 as builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

RUN adduser -u 10001 scratchuser
COPY . .
RUN CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -tags timetzdata

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/skyline ./
COPY --from=builder /etc/passwd /etc/passwd
USER scratchuser

ENTRYPOINT ["/skyline", "serve"]
