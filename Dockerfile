FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin listmonk && apk --no-cache add ca-certificates tzdata curl tar
WORKDIR /app

# escolha a versão estável
ARG LISTMONK_VERSION=3.0.0

# baixa e instala o binário oficial
RUN curl -L -o /tmp/listmonk.tar.gz \
      https://github.com/knadh/listmonk/releases/download/v${LISTMONK_VERSION}/listmonk_${LISTMONK_VERSION}_linux_amd64.tar.gz \
  && tar -xzf /tmp/listmonk.tar.gz -C /tmp \
  && mv /tmp/listmonk /app/listmonk \
  && chmod +x /app/listmonk \
  && rm -rf /tmp/*

USER listmonk
EXPOSE 9000
ENTRYPOINT ["/app/listmonk"]
