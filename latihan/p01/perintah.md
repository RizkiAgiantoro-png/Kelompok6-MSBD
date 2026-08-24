# yang kami list ini pak

docker --version
docker compose version
docker run --rm hello-world
docker compose up -d
docker compose ps
docker compose exec postgres createdb -U msbd pagila
docker compose exec postgres pg_restore -U msbd -d pagila --no-owner /dump/pagila.dump