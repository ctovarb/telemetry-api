# Etapa 0: Obtener el adaptador de AWS Lambda
FROM public.ecr.aws/awsguru/aws-lambda-adapter:0.9.0 AS aws-lambda-adapter


# Etapa 1: Construccion
FROM golang:1.26.6-alpine AS builder
WORKDIR /app
COPY src/ .

# Inicializar modulo si no existe y compilar
RUN go build -o main main.go

# Etapa 2: Imagen final ligera
FROM alpine:3.18

# Instalar curl y descargar el adaptador de AWS Lambda directamente

WORKDIR /app
COPY --from=aws-lambda-adapter /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /app/main .

ENV PORT=8080
ENV AWS_LWA_READINESS_CHECK_PATH="/health"
EXPOSE 8080

CMD ["./main"]
