# NGINX Proxy Manager Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-nginx
./manage-services.sh cleanup-nginx
./manage-services.sh reset-nginx
./manage-services.sh data-clean-nginx
```

Ports:

```text
80   HTTP
81   Admin UI
443  HTTPS
```

Persistent volumes:

```text
/opt/volumes/npm/data -> /data
/opt/volumes/npm/letsencrypt -> /etc/letsencrypt
```

Important: NGINX Proxy Manager stores UI users and settings inside `/opt/volumes/npm/data`. Running `data-clean-nginx` removes those settings and resets the UI data.
