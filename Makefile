include .env
RUN = docker-compose run --no-deps --rm -u root mapservermr

build-server:
	docker build --debug -t gaj-service:0.1 -f Dockerfile.server .

build-front:
	docker build --debug -t gaj-front:0.1 -f Dockerfile.frontend .

start:
	@docker-compose up -d

stop:
	@docker-compose down

restart: stop start

consola-server:
	./conf/shell.sh

consola-front:
	./conf/shell-front.sh

maven:
	./conf/compilar.sh

ps:
	@docker-compose ps


logs:
	docker logs -f gaj-service

rebuild:	stop build-server build-front start logs