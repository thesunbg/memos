# Stage 1: Builder với Go 1.25 chính thức
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go mod files trước để cache deps
COPY go.mod go.sum ./
RUN go mod download

# Copy toàn bộ source
COPY . .

# Build binary (Memos dùng go build -o memos ./main.go hoặc tương tự)
RUN CGO_ENABLED=0 GOOS=linux go build -o memos ./main.go  # Nếu main.go ở root; kiểm tra README nếu khác

# Stage 2: Runtime image nhẹ (alpine)
FROM alpine:latest

WORKDIR /app

# Copy binary từ builder
COPY --from=builder /app/memos .

# Copy assets nếu có (static files, templates)
COPY --from=builder /app/web ./web  # Nếu Memos có folder web/dist

# Expose port mặc định của Memos (5230)
EXPOSE 5230

# Volume cho data (SQLite hoặc config)
VOLUME /var/opt/memos

# Run memos
CMD ["./memos", "--data", "/var/opt/memos"]
