# PostgreSQL Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-postgres
./manage-services.sh cleanup-postgres
./manage-services.sh reset-postgres
./manage-services.sh data-clean-postgres
```

Before setup, create and edit credentials:

```bash
cp postgres/.env.example postgres/.env
nano postgres/.env
```

Do not leave `CHANGE_ME` values unchanged.

Persistent data volume:

```text
/opt/volumes/postgres/data -> /var/lib/postgresql/data
```

`data-clean-postgres` removes database files from `/opt/volumes/postgres/data` but does not change `postgres/.env`.
