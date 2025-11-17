# gaj-server-docker


git clone https://github.com/redondomarco/gaj-server-docker.git

cd gaj-server-docker

touch .env

git clone https://gitlab.rosario.gob.ar/externos/gaj/gaj-server-main.git

cd gaj-server-main

git checkout feature-3.1.1

cd ..

git clone https://gitlab.rosario.gob.ar/externos/gaj/gaj-frontend.git

cd gaj-frontend

git checkout feature-3.1.1

cd ..

make build-server

make build-front

make start

para entrar en el contenedor front

make consola-front

para entrar en el contenedor server

make consola-server

root@xxxxxxxxxx:/opt# compilar.sh

en la carpeta keys/ se esperan los siguientes archivos

-rw-rw-r-- 1 marco marco   5538 nov 11 18:41 application-uat2.yml.mainjuzgamiento
-rw-rw-r-- 1 marco marco   3014 nov 10 13:26 m2-settings-v2.xml
-rw-rw-r-- 1 marco marco 660401 nov  6 14:09 m_gaj.27-03-23.esquema.sql
<<<<<<< HEAD



NOTAS:

para ejecutar comandos en la db

docker exec -it gaj-db psql -U root -d gaj

psql (12.20 (Debian 12.20-1.pgdg110+1))
Type "help" for help.

gaj=# SELECT * FROM pg_catalog.pg_tables;
=======
>>>>>>> b79a047 (agrego front)
