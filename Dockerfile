# ---------- build stage ----------
FROM golang:1.24-alpine AS build
# se quiser blindar ainda mais contra mudanças futuras do go.mod:
# ENV GOTOOLCHAIN=auto

RUN apk add --no-cache git build-base
WORKDIR /src

# cache de deps
COPY go.mod go.sum ./
RUN go mod download

# código
COPY . .

# compila o binário do listmonk
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/listmonk ./cmd/listmonk

# ---------- runtime stage ----------
FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin listmonk && apk --no-cache add ca-certificates tzdata
WORKDIR /app

COPY --from=build /out/listmonk /app/listmonk
# se existir no seu fork, mantém; se não existir, remova a linha abaixo
COPY config.toml.sample /app/config.toml

USER listmonk
EXPOSE 9000
ENTRYPOINT ["/app/listmonk"]
