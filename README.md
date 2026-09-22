# QuickBite Compose Control

## Cách sử dụng

### Khởi động

```bash
./compose-control.sh start
```

### Dừng

```bash
./compose-control.sh stop
```

### Dọn dẹp

```bash
./compose-control.sh clean
```

## Chức năng

- Tự động build và khởi động Docker Compose
- Kiểm tra PostgreSQL bằng `pg_isready`
- Kiểm tra Backend qua `/actuator/health`
- In log khi lỗi
- Tự động dọn dẹp nếu khởi động thất bại
