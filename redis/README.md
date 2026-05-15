# Redis Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-redis
./manage-services.sh cleanup-redis
./manage-services.sh reset-redis
./manage-services.sh data-clean-redis
```

Before setup, create and edit credentials:

```bash
cp redis/.env.example redis/.env
nano redis/.env
```

Do not leave `CHANGE_ME` values unchanged.

Persistent data volume:

```text
/opt/volumes/redis/data -> /data
```

`data-clean-redis` removes Redis AOF/data files from `/opt/volumes/redis/data` but does not change `redis/.env`.
