# gaj-server-docker


git clone https://github.com/redondomarco/gaj-server-docker.git

cd gaj-server-docker

touch .env

git clone https://gitlab.rosario.gob.ar/externos/gaj/gaj-server-main.git

cd gaj-server-main

git checkout feature-3.1.1

cd ..

make build

make start

make consola

root@xxxxxxxxxx:/opt# compilar.sh