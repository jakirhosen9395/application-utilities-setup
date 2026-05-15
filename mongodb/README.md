# MongoDB Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-mongodb
./manage-services.sh cleanup-mongodb
./manage-services.sh reset-mongodb
./manage-services.sh data-clean-mongodb
```

Before setup, create and edit credentials:

```bash
cp mongodb/.env.example mongodb/.env
nano mongodb/.env
```

Do not leave `CHANGE_ME` values unchanged.

Persistent data volume:

```text
/opt/volumes/mongodb/data -> /data/db
```

`data-clean-mongodb` removes database files from `/opt/volumes/mongodb/data` but does not change `mongodb/.env`.
