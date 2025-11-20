include .env
RUNSRV = docker-compose run --no-deps --rm -u root gaj-service

build-server:
	docker build --debug -t gaj-service:0.1 -f Dockerfile.server .

build-front:
	docker build --debug -t gaj-front:0.1 -f Dockerfile.frontend .

start:
	@docker-compose up -d

stop:
	@docker-compose down

restart: stop start logs

consola-server:
	./conf/shell.sh

consola-front:
	./conf/shell-front.sh

maven:
	${RUN} /usr/local/bin/compilar.sh

ps:
	@docker-compose ps


logs:
	docker logs -f gaj-service

rebuild:	stop build-server build-front start logs