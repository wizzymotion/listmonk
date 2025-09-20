# ---------- build stage ----------
FROM golang:1.24-alpine AS build
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
# opcional: ajuda quando o go.mod pede toolchain específica
ENV GOTOOLCHAIN=auto

RUN apk add --no-cache git build-base
WORKDIR /src

# cache de deps
COPY go.mod go.sum ./
RUN go mod download

# código
COPY . .

# compila: se existir cmd/listmonk usa, senão compila do raiz
RUN if [ -d "cmd/listmonk" ]; then \
      echo "Building from cmd/listmonk"; \
      (cd cmd/listmonk && go build -trimpath -ldflags="-s -w" -o /out/listmonk .); \
    else \
      echo "Building from module root"; \
      go build -trimpath -ldflags="-s -w" -o /out/listmonk .; \
    fi

# ---------- runtime stage ----------
FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin listmonk && apk --no-cache add ca-certificates tzdata
WORKDIR /app
COPY --from=build /out/listmonk /app/listmonk
USER listmonk
EXPOSE 9000
ENTRYPOINT ["/app/listmonk"]
