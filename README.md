# Application Utilities Setup

This repository contains Docker Compose based setup files for common application utilities:

- Elastic APM, Elasticsearch, Kibana, and ILM scripts
- PostgreSQL
- MongoDB
- Redis
- Kafka and Kafka UI
- RustFS object storage
- NGINX Proxy Manager
- Docker installation notes
- Vagrant server examples
- GitHub setup documentation

The main root-level script is:

```bash
./manage-services.sh
```

Run every command from the project root directory because the script uses:

```bash
path="$(pwd)"
```

---

## 1. Copy-Paste Quick Start

### Step 1: Go to the project root

```bash
cd application-utilities-setup
```

### Step 2: Make the management script executable

```bash
chmod +x manage-services.sh
```

### Step 3: Create all `.env` files from examples

```bash
sudo cp elastic-apm/.env.example elastic-apm/.env
sudo cp postgres/.env.example postgres/.env
sudo cp mongodb/.env.example mongodb/.env
sudo cp redis/.env.example redis/.env
sudo cp kafka/.env.example kafka/.env
sudo cp rustfs/.env.example rustfs/.env
```

### Step 4: Change every password and required value

Edit these files before running setup:

```bash
sudo vi elastic-apm/.env
sudo vi postgres/.env
sudo vi mongodb/.env
sudo vi redis/.env
sudo vi kafka/.env
sudo vi rustfs/.env
```

Check these files before running setup:

```bash
cat elastic-apm/.env
cat postgres/.env
cat mongodb/.env
cat redis/.env
cat kafka/.env
cat rustfs/.env
```

Do not leave any `CHANGE_ME` value unchanged.

Generate strong passwords with:

```bash
openssl rand -base64 32
```

Generate the Kibana encryption key with exactly 32 characters:

```bash
openssl rand -base64 32 | head -c 32; echo
```

For Kafka, update this value in `kafka/.env`:

```bash
KAFKA_EXTERNAL_HOST=YOUR_SERVER_IP_OR_DOMAIN
```

Example:

```bash
KAFKA_EXTERNAL_HOST=172.31.39.197
```

### Step 5: Setup all utilities

```bash
./manage-services.sh setup-all
```

### Step 6: Check running containers

```bash
./manage-services.sh status
```

### Step 7: Cleanup all utilities without deleting data

```bash
./manage-services.sh cleanup-all
```

### Step 8: Restart all utilities without deleting data

```bash
./manage-services.sh reset-all
```

### Step 9: Remove all utility data without changing `.env` credentials

```bash
./manage-services.sh data-clean-all
```

After data-clean, run setup again:

```bash
./manage-services.sh setup-all
```

---

## 2. Important Password Rule

Before each first setup on a new server, you must change all default/example credentials.

Credential files:

| Utility                              | Credential File    | Must Change                                                                        |
| ------------------------------------ | ------------------ | ---------------------------------------------------------------------------------- |
| Elastic APM / Elasticsearch / Kibana | `elastic-apm/.env` | `ELASTIC_PASSWORD`, `KIBANA_PASSWORD`, `KIBANA_ENCRYPTION_KEY`, `APM_SECRET_TOKEN` |
| PostgreSQL                           | `postgres/.env`    | `POSTGRES_PASSWORD`; optionally change `POSTGRES_USER` and `POSTGRES_DB`           |
| MongoDB                              | `mongodb/.env`     | `MONGO_INITDB_ROOT_PASSWORD`; optionally change username and database              |
| Redis                                | `redis/.env`       | `REDIS_PASSWORD`                                                                   |
| Kafka                                | `kafka/.env`       | `KAFKA_EXTERNAL_HOST`; keep `KAFKA_CLUSTER_ID` stable after data exists            |
| RustFS                               | `rustfs/.env`      | `RUSTFS_ACCESS_KEY`, `RUSTFS_SECRET_KEY`                                           |
| NGINX Proxy Manager                  | Web UI             | Change the admin account after first login                                         |

The script will stop setup if a `.env` file still contains `CHANGE_ME`.

Data-clean commands remove persistent data but do not edit `.env` files. This means credentials stay the same for Postgres, MongoDB, Redis, Kafka, RustFS, and Elastic APM.

Special note for NGINX Proxy Manager: user accounts and UI settings are stored inside `/opt/volumes/npm/data`. Running `data-clean-nginx` removes that data, so the NGINX Proxy Manager UI account will reset.

---

## 3. Command Reference

### All utilities

```bash
./manage-services.sh setup-all
./manage-services.sh cleanup-all
./manage-services.sh reset-all
./manage-services.sh data-clean-all
./manage-services.sh status
```

Meaning:

| Command          | What It Does                                                 | Data Removed? |        Credentials Changed? |
| ---------------- | ------------------------------------------------------------ | ------------: | --------------------------: |
| `setup-all`      | Starts all utilities and creates required volume directories |            No |                          No |
| `cleanup-all`    | Stops all utilities                                          |            No |                          No |
| `reset-all`      | Runs cleanup then setup again                                |            No |                          No |
| `data-clean-all` | Stops utilities and deletes persistent data directories      |           Yes | No `.env` files are changed |
| `status`         | Shows Docker container status                                |            No |                          No |

---

## 4. Individual Utility Commands

### Elastic APM, Elasticsearch, Kibana

```bash
./manage-services.sh setup-elastic-apm
./manage-services.sh cleanup-elastic-apm
./manage-services.sh reset-elastic-apm
./manage-services.sh data-clean-elastic-apm
```

### PostgreSQL

```bash
./manage-services.sh setup-postgres
./manage-services.sh cleanup-postgres
./manage-services.sh reset-postgres
./manage-services.sh data-clean-postgres
```

### MongoDB

```bash
./manage-services.sh setup-mongodb
./manage-services.sh cleanup-mongodb
./manage-services.sh reset-mongodb
./manage-services.sh data-clean-mongodb
```

### Redis

```bash
./manage-services.sh setup-redis
./manage-services.sh cleanup-redis
./manage-services.sh reset-redis
./manage-services.sh data-clean-redis
```

### Kafka

```bash
./manage-services.sh setup-kafka
./manage-services.sh cleanup-kafka
./manage-services.sh reset-kafka
./manage-services.sh data-clean-kafka
```

### RustFS

```bash
./manage-services.sh setup-rustfs
./manage-services.sh cleanup-rustfs
./manage-services.sh reset-rustfs
./manage-services.sh data-clean-rustfs
```

### NGINX Proxy Manager

```bash
./manage-services.sh setup-nginx
./manage-services.sh cleanup-nginx
./manage-services.sh reset-nginx
./manage-services.sh data-clean-nginx
```

---

## 5. Persistent Volume Paths

All persistent service data is stored under `/opt/volumes`.

| Utility                          | Host Volume Path                              | Container Path                  |
| -------------------------------- | --------------------------------------------- | ------------------------------- |
| ElasticSearch                    | `/opt/volumes/elastic-apm/elasticsearch-data` | `/usr/share/elasticsearch/data` |
| PostgreSQL                       | `/opt/volumes/postgres/data`                  | `/var/lib/postgresql/data`      |
| MongoDB                          | `/opt/volumes/mongodb/data`                   | `/data/db`                      |
| Redis                            | `/opt/volumes/redis/data`                     | `/data`                         |
| Kafka                            | `/opt/volumes/kafka/data`                     | `/var/lib/kafka/data`           |
| RustFS data                      | `/opt/volumes/rustfs/data/rustfs-data`        | `/data`                         |
| RustFS logs                      | `/opt/volumes/rustfs/data/rustfs-logs`        | `/logs`                         |
| NGINX Proxy Manager data         | `/opt/volumes/npm/data`                       | `/data`                         |
| NGINX Proxy Manager certificates | `/opt/volumes/npm/letsencrypt`                | `/etc/letsencrypt`              |

The script creates these directories automatically during setup.

To inspect data manually:

```bash
sudo ls -lah /opt/volumes
```

To check a specific utility volume:

```bash
sudo ls -lah /opt/volumes/postgres/data
sudo ls -lah /opt/volumes/mongodb/data
sudo ls -lah /opt/volumes/redis/data
sudo ls -lah /opt/volumes/kafka/data
sudo ls -lah /opt/volumes/rustfs/data
sudo ls -lah /opt/volumes/npm
```

RustFS permission note:

- RustFS runs inside the container as UID/GID `10001`.
- The script sets RustFS host directories to `10001:10001` and permission `755`.
- This prevents the `Permission denied (os error 13)` restart loop on `/data` or the log directory.
- If you manually create or restore RustFS data, fix permissions again with:

```bash
sudo chown -R 10001:10001 /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs
sudo chmod -R 755 /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs
./manage-services.sh reset-rustfs
```

---

## 6. Data Clean Commands

Use `data-clean-*` when you want to remove all stored data for a utility but keep the same credentials/configuration files.

### Clean all data

```bash
./manage-services.sh data-clean-all
```

Then setup all again:

```bash
./manage-services.sh setup-all
```

### Clean only one utility data

```bash
./manage-services.sh data-clean-postgres
./manage-services.sh setup-postgres
```

```bash
./manage-services.sh data-clean-mongodb
./manage-services.sh setup-mongodb
```

```bash
./manage-services.sh data-clean-redis
./manage-services.sh setup-redis
```

```bash
./manage-services.sh data-clean-kafka
./manage-services.sh setup-kafka
```

```bash
./manage-services.sh data-clean-rustfs
./manage-services.sh setup-rustfs
```

```bash
./manage-services.sh data-clean-elastic-apm
./manage-services.sh setup-elastic-apm
```

```bash
./manage-services.sh data-clean-nginx
./manage-services.sh setup-nginx
```

Important:

- `cleanup-*` only stops containers.
- `reset-*` stops and starts containers again.
- `data-clean-*` stops containers and removes persistent data directories.
- `data-clean-*` does not edit `.env` credential files.
- For NGINX Proxy Manager, `data-clean-nginx` removes UI users/settings because those are stored in its data volume.

---

## 7. Utility Access and Usage

### Elastic APM / Elasticsearch / Kibana

URLs:

```text
Elasticsearch: http://localhost:9200
Kibana:        http://localhost:5601
APM Server:    http://localhost:8200
```

Credentials are stored in:

```bash
elastic-apm/.env
```

Check status:

```bash
cd elastic-apm
./setup.sh --status
```

View logs:

```bash
docker logs -f elasticsearch
docker logs -f kibana
docker logs -f apm-server
```

APM application configuration example:

```text
APM_SERVER_URL=http://YOUR_SERVER_IP:8200
APM_SECRET_TOKEN=<value from elastic-apm/.env>
```

Apply the 15-day ILM policy manually:

```bash
cd elastic-apm
chmod +x ilm-15-day-retention.sh cleanup-old-indices.sh disk-usage-monitor.sh
./ilm-15-day-retention.sh
```

---

### PostgreSQL

Host port:

```text
5432
```

Credentials are stored in:

```bash
postgres/.env
```

Example connection URI:

```text
postgresql://POSTGRES_USER:POSTGRES_PASSWORD@YOUR_SERVER_IP:5432/POSTGRES_DB
```

Open psql inside the container:

```bash
docker exec -it postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

If you are running from the host shell, first load the `.env` file:

```bash
cd postgres
set -a
source .env
set +a
docker exec -it postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

View logs:

```bash
docker logs -f postgres
```

---

### MongoDB

Host port:

```text
27017
```

Credentials are stored in:

```bash
mongodb/.env
```

Example connection URI:

```text
mongodb://MONGO_INITDB_ROOT_USERNAME:MONGO_INITDB_ROOT_PASSWORD@YOUR_SERVER_IP:27017/MONGO_INITDB_DATABASE?authSource=admin
```

Open Mongo shell inside the container:

```bash
cd mongodb
set -a
source .env
set +a
docker exec -it mongodb mongosh -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin
```

View logs:

```bash
docker logs -f mongodb
```

---

### Redis

Host port:

```text
6379
```

Credentials are stored in:

```bash
redis/.env
```

Connect with Redis CLI:

```bash
cd redis
set -a
source .env
set +a
docker exec -it redis8.0 redis-cli -a "$REDIS_PASSWORD" --no-auth-warning
```

Test Redis:

```bash
ping
```

Expected result:

```text
PONG
```

View logs:

```bash
docker logs -f redis8.0
```

---

### Kafka

Ports:

```text
9092   external clients
29092  internal Docker/network clients
8080   Kafka UI
```

Configuration is stored in:

```bash
kafka/.env
```

Important:

```bash
KAFKA_EXTERNAL_HOST=YOUR_SERVER_IP_OR_DOMAIN
```

External application bootstrap server:

```text
YOUR_SERVER_IP_OR_DOMAIN:9092
```

Internal Docker-network bootstrap server:

```text
kafka:29092
```

Kafka UI:

```text
http://YOUR_SERVER_IP:8080
```

List topics:

```bash
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka:29092 --list
```

Create a topic:

```bash
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka:29092 --create --topic test-topic --partitions 1 --replication-factor 1
```

Produce test message:

```bash
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka:29092 --topic test-topic
```

Consume test message:

```bash
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:29092 --topic test-topic --from-beginning
```

View logs:

```bash
docker logs -f kafka
docker logs -f kafka-ui
```

---

### RustFS

Ports:

```text
9000  API
9001  Console/UI
```

Credentials are stored in:

```bash
rustfs/.env
```

Endpoints:

```text
RustFS API:     http://YOUR_SERVER_IP:9000
RustFS Console: http://YOUR_SERVER_IP:9001
```

S3-compatible values for applications:

```text
S3_ENDPOINT=http://YOUR_SERVER_IP:9000
S3_ACCESS_KEY=<value from rustfs/.env>
S3_SECRET_KEY=<value from rustfs/.env>
S3_FORCE_PATH_STYLE=true
```

View logs:

```bash
docker logs -f rustfs
```

---

### NGINX Proxy Manager

Ports:

```text
80    HTTP
81    Admin UI
443   HTTPS
```

Access the UI:

```text
http://YOUR_SERVER_IP:81
```

After first login, change the admin email and password immediately from the web UI.

Volumes:

```text
/opt/volumes/npm/data
/opt/volumes/npm/letsencrypt
```

View logs:

```bash
docker logs -f nginx-proxy-manager
```

---

## RustFS Permission Fix

If RustFS keeps restarting and logs show this error:

```text
Server encountered an error and is shutting down: Io error: Permission denied (os error 13)
```

Run this from the project root:

```bash
./manage-services.sh cleanup-rustfs
sudo chown -R 10001:10001 /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs
sudo chmod -R 755 /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs
./manage-services.sh setup-rustfs
docker logs -f rustfs
```

To remove RustFS object data and logs while keeping the same `rustfs/.env` credentials:

```bash
./manage-services.sh data-clean-rustfs
./manage-services.sh setup-rustfs
```

---

## 8. Recommended Setup Order

For a new server, use this order:

```bash
chmod +x manage-services.sh

cp elastic-apm/.env.example elastic-apm/.env
cp postgres/.env.example postgres/.env
cp mongodb/.env.example mongodb/.env
cp redis/.env.example redis/.env
cp kafka/.env.example kafka/.env
cp rustfs/.env.example rustfs/.env

nano elastic-apm/.env
nano postgres/.env
nano mongodb/.env
nano redis/.env
nano kafka/.env
nano rustfs/.env

./manage-services.sh setup-all
./manage-services.sh status
```

---

## 9. Docker Installation

Docker installation notes are available in:

```text
Docker/README.md
```

Basic Docker install commands:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"
newgrp docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

Verify:

```bash
docker --version
docker compose version
docker run hello-world
```

---

## 10. Repository Structure

```text
.
├── Docker/
├── elastic-apm/
├── kafka/
├── mongodb/
├── nginx/
├── postgres/
├── redis/
├── rustfs/
├── servers/
├── setup-github/
├── README.md
├── command.sh
└── manage-services.sh
```

Notes:

- `manage-services.sh` is the main utility management script.
- `command.sh` is kept as a copy of `manage-services.sh` for compatibility.
- `setup-github/README.md` contains Git and GitHub workflow documentation.
- `postgres/postgres_migration_guide.md` contains PostgreSQL migration notes.
- `mongodb/mongodb_migration_guide.md` contains MongoDB migration notes.

---

## 11. Safety Notes

- Never commit real `.env` files.
- Always change every example password before setup.
- Keep Kafka `KAFKA_CLUSTER_ID` stable after Kafka data exists.
- Run `data-clean-*` only when you intentionally want to delete that utility data.
- Back up `/opt/volumes` before cleaning production data.
- Do not run this stack on a public server without firewall rules and strong credentials.
