#!/bin/bash

# Dừng tất cả các script nếu có lỗi xảy ra
set -e

echo "=== BƯỚC 1: Tạo Custom Bridge Network (app-net) ==="
docker network create app-net || echo "Network app-net đã tồn tại."

echo "=== BƯỚC 2: Tạo Named Volume (db-data) ==="
docker volume create db-data || echo "Volume db-data đã tồn tại."

echo "=== BƯỚC 3: Khởi chạy Database Container (db-server) ==="
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_DB=mydb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

echo "Đang đợi PostgreSQL khởi động hoàn toàn..."
sleep 5

echo "=== BƯỚC 4: Khởi chạy Backend Container (app-container) ==="
# Lưu ý: Thay thế 'hw-backend:multistage' bằng image thực tế của bạn từ Bài 3
docker run -d \
  --name app-container \
  --network app-net \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://db-server:5432/mydb \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=secret \
  hw-backend:multistage

echo "=== Hoàn tất! Tất cả container đã khởi chạy thành công trên mạng app-net ==="