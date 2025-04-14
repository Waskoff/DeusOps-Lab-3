# -----------------------------
# Stage 1: Сборка приложения
# -----------------------------

FROM golang:1.19-alpine AS builder

# Установка необходимых утилит (например, git) с применением флага --no-cache для очистки кеша
RUN apk update && apk add --no-cache git

WORKDIR /app

# Копируем файлы зависимостей для более эффективного использования кэширования
COPY go.mod go.sum ./
RUN go mod download

# Копируем файлы зависимостей
COPY go.mod go.sum ./

# Копируем исходный код приложения
COPY main.go ./


# Компиляция приложения:
# - CGO_ENABLED=0 — отключение CGO для получения статически слинкованного бинарника
# - GOOS=linux — сборка для Linux
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# -----------------------------
# Stage 2: Финальный образ
# -----------------------------
FROM alpine:3.18

# Создаем группу и пользователя (непривилегированного) для запуска контейнера
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Задаем переменную окружения с дефолтным значением
ENV GREETING="Hello from Docker multi-stage build!"

# Копируем собранный бинарный файл из предыдущего этапа
COPY --from=builder /app/app /app/app

# Меняем владельца бинарного файла на непривилегированного пользователя
RUN chown appuser:appgroup /app/app

# Переключаемся на непривилегированного пользователя
USER appuser

WORKDIR /app

# Определяем команду запуска
ENTRYPOINT ["./app"]
    