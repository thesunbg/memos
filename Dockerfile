# Stage 1: Builder với Go 1.25
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go mod trước để cache deps
COPY go.mod go.sum ./
RUN go mod download

# Copy toàn bộ source
COPY . .

# Build binary - path đúng là cmd/memos/main.go
RUN CGO_ENABLED=0 GOOS=linux go build -o memos ./cmd/memos

# Stage 2: Runtime image nhẹ
FROM alpine:latest

WORKDIR /app

# Copy binary
COPY --from=builder /app/memos .

# Copy web assets (Memos có frontend build sẵn hoặc static)
COPY --from=builder /app/web ./web

# Expose port
EXPOSE 5230

# Volume cho data (SQLite file, attachments, etc.)
VOLUME /var/opt/memos

# Run với data path
CMD ["./memos", "--data", "/var/opt/memos"]
