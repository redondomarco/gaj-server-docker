# gaj-server-docker

# Clonamos este repo y creamos el archivo .env
```
git clone https://github.com/redondomarco/gaj-server-docker.git

cd gaj-server-docker

touch .env

```

# Requerida la fuente del server, en la version deseada

```
git clone https://gitlab.rosario.gob.ar/externos/gaj/gaj-server-main.git

cd gaj-server-main

git checkout feature-3.1.1

cd ..
```

# requerida la fuente del front, en la version deseada

```
git clone https://gitlab.rosario.gob.ar/externos/gaj/gaj-frontend.git

cd gaj-frontend

git checkout feature-3.1.1

cd ..
```
# requeridas credenciales

en la carpeta keys/ se esperan los siguientes archivos

```
-rw-rw-r-- 1 marco marco   5538 nov 11 18:41 application-uat2.yml.mainjuzgamiento
-rw-rw-r-- 1 marco marco   3014 nov 10 13:26 m2-settings-v2.xml
-rw-rw-r-- 1 marco marco 660401 nov  6 14:09 m_gaj.27-03-23.esquema.sql
```

# construimos las imagenes de los contenedores
```
make build-server

make build-front
```

# iniciamos server, db y front

make start

# Server

para entrar en el contenedor server
```
make consola-server
```

una vez dentro generamos el war

```
root@xxxxxxxxxx:/opt# compilar.sh
```


# Front 

para entrar en el contenedor front
```
make consola-front
```


# DB

para ejecutar comandos en la db

```
docker exec -it gaj-db psql -U root -d gaj
```

```
psql (12.20 (Debian 12.20-1.pgdg110+1))
Type "help" for help.

gaj=# SELECT * FROM pg_catalog.pg_tables;
```

para guardar un dump de la base:

docker exec -t gaj-db pg_dumpall -c -U root > dump_$(date +%Y-%m-%d_%H_%M_%S).sql

para restaurarlo

make stop

sudo rm data/pg/*

cat keys/dump_2025-12-09_15_14_17.sql | docker exec -i gaj-db psql -U root -d gaj