all:up

up: setup
	docker compose -f srcs/docker-compose.yml build --no-cache
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	rm -rf /home/ahmet/data/mariadb/
	rm -rf /home/ahmet/data/wordpress/
	docker compose -f srcs/docker-compose.yml down -v

re: clean up

setup:
	mkdir -p /home/ahmet/data/mariadb
	mkdir -p /home/ahmet/data/wordpress
