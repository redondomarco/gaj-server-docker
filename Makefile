include .env
RUN = docker-compose run --no-deps --rm -u root mapservermr

build:
	docker build --debug -t tomcat9java11:0.1 .

start:
	@docker-compose up -d

stop:
	@docker-compose down

restart: stop start

consola:
	./conf/shell.sh

maven:
	./conf/compilar.sh