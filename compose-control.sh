#!/bin/bash

# =========================
# QUICKBITE CONTROL SCRIPT
# =========================

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

DB_SERVICE="postgres"
BACKEND_SERVICE="backend"

DB_TIMEOUT=10
API_TIMEOUT=10

case "$1" in

start)

    echo -e "${YELLOW}Khởi động QuickBite...${NC}"

    docker compose up -d --build

    echo "Đợi PostgreSQL sẵn sàng..."

    elapsed=0

    while [ $elapsed -lt $DB_TIMEOUT ]
    do
        if docker compose exec -T $DB_SERVICE pg_isready -U postgres >/dev/null 2>&1
        then
            echo "PostgreSQL đã sẵn sàng."
            break
        fi

        sleep 2
        elapsed=$((elapsed+2))
    done

    if [ $elapsed -ge $DB_TIMEOUT ]
    then
        echo -e "${RED}LỖI: PostgreSQL không sẵn sàng sau ${DB_TIMEOUT}s.${NC}"

        echo "20 dòng log cuối của backend:"
        docker compose logs --tail=20 $BACKEND_SERVICE

        docker compose down

        exit 1
    fi

    echo "Đợi Backend Health..."

    elapsed=0

    while [ $elapsed -lt $API_TIMEOUT ]
    do
        STATUS=$(curl -s http://localhost:8080/actuator/health | grep -o '"status":"UP"')

        if [ "$STATUS" = '"status":"UP"' ]
        then
            echo -e "${GREEN}HỆ THỐNG QUICKBITE HOẠT ĐỘNG ỔN ĐỊNH!${NC}"
            exit 0
        fi

        sleep 2
        elapsed=$((elapsed+2))
    done

    echo -e "${RED}LỖI: Backend Health Check thất bại.${NC}"

    echo "20 dòng log cuối của backend:"
    docker compose logs --tail=20 $BACKEND_SERVICE

    docker compose down

    exit 1
;;

stop)

    echo "Dừng hệ thống..."

    docker compose stop

    echo "Đã dừng."

;;

clean)

    echo "Dọn dẹp hệ thống..."

    docker compose down -v

    echo "Đã dọn dẹp hoàn tất."

;;

*)

    echo "Sử dụng:"
    echo "./compose-control.sh start"
    echo "./compose-control.sh stop"
    echo "./compose-control.sh clean"
    exit 1

;;

esac