# Etapa 0: Obtener el adaptador de AWS Lambda
FROM public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 AS adapter

# Etapa 1: Construccion
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY src/ .

# Inicializar modulo si no existe y compilar
RUN go build -o main main.go

# Etapa 2: Imagen final ligera
FROM alpine:3.18

# Instalar curl y descargar el adaptador de AWS Lambda directamente
RUN apk add --no-cache curl && \
    mkdir -p /opt/extensions && \
    curl -sSL https://github.com/awslabs/aws-lambda-web-adapter/releases/download/v0.8.4/lambda-adapter-x86_64 -o /opt/extensions/lambda-adapter && \
    chmod +x /opt/extensions/lambda-adapter

WORKDIR /app
COPY --from=builder /app/main .

ENV PORT=8080
EXPOSE 8080

CMD ["./main"]
