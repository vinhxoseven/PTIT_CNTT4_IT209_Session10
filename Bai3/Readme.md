# Bài 3: Tối ưu hóa dung lượng Image & Layer Caching với Multi-stage Build

## 1. Mục tiêu
Áp dụng kỹ thuật **Multi-stage Build** và tối ưu **Layer Caching** nhằm giảm thiểu tối đa dung lượng Docker Image của ứng dụng Web Backend (Java Spring Boot), đồng thời tăng tốc quá trình build và đảm bảo bảo mật cho môi trường Production.

---

## 2. Bảng so sánh chi tiết (`hw-backend:single` vs `hw-backend:multistage`)

| Tiêu chí so sánh | `hw-backend:single` (Single-stage) | `hw-backend:multistage` (Multi-stage) | Đánh giá / Cải thiện |
| :--- | :--- | :--- | :--- |
| **Base Image** | `maven:3.9-eclipse-temurin-17-alpine` | `eclipse-temurin:17-jre-alpine` | Loại bỏ hoàn toàn Maven CLI và JDK nặng khỏi Production image. |
| **Dung lượng Image** | ~ 750 MB - 900 MB | ~ 180 MB - 220 MB | **Giảm ~ 70-75%** dung lượng, đạt yêu cầu tối ưu. |
| **Số lượng Layer** | 12 - 15 layers | 6 - 8 layers | Giảm số lượng layer trung gian không cần thiết. |
| **Build Cache Optimization** | Kém (Thay đổi mã nguồn nhỏ phải tải và build lại toàn bộ Maven dependencies). | Tốt (Tách riêng `pom.xml` và `src`, tận dụng cache thư viện). | Tăng tốc độ tái build đáng kể khi chỉ thay đổi source code logic. |
| **Mức độ bảo mật** | Thấp (Chứa nhiều công cụ biên dịch tiềm ẩn lỗ hổng). | Cao (Chỉ chứa JRE và file JAR thực thi tối thiểu). | Giảm bề mặt tấn công (Attack Surface). |

---

## 3. Hướng dẫn kiểm tra và chạy thử

### Bước 1: Build Single-stage Image
```bash
docker build -t hw-backend:single -f Dockerfile.single .
Bước 2: Build Multi-stage Image
Bash
docker build -t hw-backend:multistage -f Dockerfile .
Bước 3: Kiểm tra dung lượng Image
Bash
docker images | grep hw-backend
Bước 4: Kiểm tra hoạt động của Container
Bash
docker run -d -p 8080:8080 --name backend-prod hw-backend:multistage
Truy cập endpoint kiểm tra API để xác nhận ứng dụng phản hồi chính xác.

Bash
curl http://localhost:8080/api/health