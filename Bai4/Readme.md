# Bài 4: Thiết lập Custom Network & Named Volume bằng Docker CLI

## 1. Mục tiêu
- Tạo Custom Bridge Network (`app-net`) để các container phân giải tên miền nội bộ (DNS resolution) qua tên service thay vì dùng IP tĩnh.
- Sử dụng Named Volume (`db-data`) để đảm bảo dữ liệu của cơ sở dữ liệu PostgreSQL không bị mất khi container bị xóa hoặc tái tạo.

---

## 2. Hướng dẫn kiểm tra hệ thống

### Bước 1: Kiểm tra Network và Volume đã tạo
Chạy các lệnh sau để xác thực:
```bash
docker network ls | grep app-net
docker volume ls | grep db-data
Xác minh thành công: Danh sách trả về hiển thị chính xác network app-net và volume db-data.

Bước 2: Kiểm tra khả năng phân giải DNS nội bộ (Ping test)
Thực hiện lệnh kiểm tra mạng nội bộ từ Backend container đến Database container:

Bash
docker exec -it app-container ping -c 2 db-server
Xác minh thành công: Lệnh ping phân giải thành công tên db-server thành địa chỉ IP nội bộ bên trong app-net và nhận các gói tin phản hồi (0% packet loss).

3. Kiểm chứng Data Persistence (Độ bền vững dữ liệu)
Để chứng minh dữ liệu cơ sở dữ liệu được lưu trữ an toàn qua Named Volume, thực hiện kịch bản kiểm tra sau:

Ghi dữ liệu: Tương tác với ứng dụng Backend hoặc kết nối vào PostgreSQL container (db-server) để tạo một bản ghi dữ liệu mới trong cơ sở dữ liệu.

Xóa cứng Database Container:

Bash
docker rm -f db-server
(Container cũ chứa toàn bộ cơ sở dữ liệu bị xóa hoàn toàn khỏi hệ thống).

Khởi chạy lại Database Container mới gắn cùng Volume cũ (db-data):

Bash
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_DB=mydb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine
Kết quả kiểm chứng: Khi container mới khởi động và kết nối lại với backend, dữ liệu trước đó hoàn toàn nguyên vẹn nhờ cơ chế lưu trữ của db-data volume nằm ngoài vòng đời của container.


<Elicitations message="Bạn có muốn thực hiện bước tiếp theo nào không?">
  <Elicitation label="Cấu hình Docker Compose cho hệ thống" query="Hãy hướng dẫn tôi cách viết file docker-compose.yml để thay thế script thủ công này cho cả backend và database."/>
  <Elicitation label="Kiểm tra kết nối DB từ Spring Boot" query="Làm thế nào để kiểm tra kết nối từ ứng dụng Spring Boot tới container PostgreSQL qua biến môi trường?"/>
</Elicitations>