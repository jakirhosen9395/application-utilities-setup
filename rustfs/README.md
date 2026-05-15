# RustFS Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-rustfs
./manage-services.sh cleanup-rustfs
./manage-services.sh reset-rustfs
./manage-services.sh data-clean-rustfs
```

Before setup, create and edit credentials:

```bash
cp rustfs/.env.example rustfs/.env
nano rustfs/.env
```

Do not leave `CHANGE_ME` values unchanged.

Persistent volumes:

```text
/opt/volumes/rustfs/data/rustfs-data -> /data
/opt/volumes/rustfs/data/rustfs-logs -> /logs
```

`data-clean-rustfs` removes RustFS data/log files but does not change `rustfs/.env`.
