#!/usr/bin/env bash

set -e

# Project root directory.
# Run this script from your project root directory.
path="$(pwd)"

# ============================================================
# Common Process
# ============================================================

prepare_env_file() {
  service_dir="$1"
  require_changed_passwords="${2:-yes}"

  cd "${path}/${service_dir}"

  if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Created ${service_dir}/.env from ${service_dir}/.env.example"
  fi

  if [ "${require_changed_passwords}" = "yes" ] && [ -f ".env" ]; then
    if grep -q "CHANGE_ME" .env; then
      echo "ERROR: ${service_dir}/.env still contains CHANGE_ME values."
      echo "Edit ${service_dir}/.env and replace all CHANGE_ME values before setup."
      exit 1
    fi
  fi
}

show_status() {
  cd "${path}"
  docker ps -a
}

# ============================================================
# Elastic APM, Elasticsearch, Kibana, and ILM
# ============================================================

setup_elastic_apm() {
  prepare_env_file "elastic-apm" "yes"

  sudo mkdir -p /opt/volumes/elastic-apm/elasticsearch-data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/elastic-apm
  sudo chmod -R 775 /opt/volumes/elastic-apm

  chmod +x setup.sh
  ./setup.sh

  chmod +x ilm-15-day-retention.sh cleanup-old-indices.sh disk-usage-monitor.sh
  ./ilm-15-day-retention.sh
}

cleanup_elastic_apm() {
  cd "${path}/elastic-apm"

  chmod +x setup.sh
  ./setup.sh --stop
}

data_clean_elastic_apm() {
  cd "${path}/elastic-apm"

  chmod +x setup.sh
  ./setup.sh --stop || true
  docker compose down -v || true

  sudo rm -rf /opt/volumes/elastic-apm/elasticsearch-data
  sudo mkdir -p /opt/volumes/elastic-apm/elasticsearch-data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/elastic-apm
  sudo chmod -R 775 /opt/volumes/elastic-apm

  echo "Elastic APM data removed. Credentials in elastic-apm/.env were not changed."
}

reset_elastic_apm() {
  cleanup_elastic_apm
  setup_elastic_apm
}

# ============================================================
# Postgres
# ============================================================

setup_postgres() {
  prepare_env_file "postgres" "yes"

  sudo mkdir -p /opt/volumes/postgres/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/postgres
  sudo chmod -R 775 /opt/volumes/postgres

  docker compose up -d --build
}

cleanup_postgres() {
  prepare_env_file "postgres" "no"

  docker compose down
}

data_clean_postgres() {
  prepare_env_file "postgres" "no"

  docker compose down -v || true
  sudo rm -rf /opt/volumes/postgres/data
  sudo mkdir -p /opt/volumes/postgres/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/postgres
  sudo chmod -R 775 /opt/volumes/postgres

  echo "Postgres data removed. Credentials in postgres/.env were not changed."
}

reset_postgres() {
  cleanup_postgres
  setup_postgres
}

# ============================================================
# MongoDB
# ============================================================

setup_mongodb() {
  prepare_env_file "mongodb" "yes"

  sudo mkdir -p /opt/volumes/mongodb/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/mongodb
  sudo chmod -R 775 /opt/volumes/mongodb

  docker compose up -d --build
}

cleanup_mongodb() {
  prepare_env_file "mongodb" "no"

  docker compose down
}

data_clean_mongodb() {
  prepare_env_file "mongodb" "no"

  docker compose down -v || true
  sudo rm -rf /opt/volumes/mongodb/data
  sudo mkdir -p /opt/volumes/mongodb/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/mongodb
  sudo chmod -R 775 /opt/volumes/mongodb

  echo "MongoDB data removed. Credentials in mongodb/.env were not changed."
}

reset_mongodb() {
  cleanup_mongodb
  setup_mongodb
}

# ============================================================
# Redis
# ============================================================

setup_redis() {
  prepare_env_file "redis" "yes"

  sudo mkdir -p /opt/volumes/redis/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/redis
  sudo chmod -R 775 /opt/volumes/redis

  docker compose up -d --build
}

cleanup_redis() {
  prepare_env_file "redis" "no"

  docker compose down
}

data_clean_redis() {
  prepare_env_file "redis" "no"

  docker compose down -v || true
  sudo rm -rf /opt/volumes/redis/data
  sudo mkdir -p /opt/volumes/redis/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/redis
  sudo chmod -R 775 /opt/volumes/redis

  echo "Redis data removed. Credentials in redis/.env were not changed."
}

reset_redis() {
  cleanup_redis
  setup_redis
}

# ============================================================
# Kafka
# ============================================================

setup_kafka() {
  prepare_env_file "kafka" "yes"

  sudo mkdir -p /opt/volumes/kafka/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/kafka
  sudo chmod -R 775 /opt/volumes/kafka

  docker compose up -d --build
}

cleanup_kafka() {
  prepare_env_file "kafka" "no"

  docker compose down
}

data_clean_kafka() {
  prepare_env_file "kafka" "no"

  docker compose down -v || true
  sudo rm -rf /opt/volumes/kafka/data
  sudo mkdir -p /opt/volumes/kafka/data
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/kafka
  sudo chmod -R 775 /opt/volumes/kafka

  echo "Kafka data removed. Kafka configuration in kafka/.env was not changed."
}

reset_kafka() {
  cleanup_kafka
  setup_kafka
}

# ============================================================
# RustFS
# ============================================================

setup_rustfs() {
  prepare_env_file "rustfs" "yes"

  sudo mkdir -p \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  # RustFS container runs as UID/GID 10001.
  # The host bind-mounted directories must be owned by 10001,
  # otherwise RustFS fails with Permission denied on /data or logs.
  sudo chown -R 10001:10001 \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  sudo chmod -R 755 \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  docker compose up -d --build
}

cleanup_rustfs() {
  prepare_env_file "rustfs" "no"

  docker compose down
}

data_clean_rustfs() {
  prepare_env_file "rustfs" "no"

  docker compose down -v || true
  sudo rm -rf \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  sudo mkdir -p \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  # RustFS container runs as UID/GID 10001.
  # The host bind-mounted directories must be owned by 10001,
  # otherwise RustFS fails with Permission denied on /data or logs.
  sudo chown -R 10001:10001 \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  sudo chmod -R 755 \
    /opt/volumes/rustfs/data/rustfs-data \
    /opt/volumes/rustfs/data/rustfs-logs

  echo "RustFS data and logs removed. Credentials in rustfs/.env were not changed."
}

reset_rustfs() {
  cleanup_rustfs
  setup_rustfs
}

# ============================================================
# NGINX Proxy Manager
# ============================================================

setup_nginx() {
  cd "${path}/nginx"

  sudo mkdir -p /opt/volumes/npm/data /opt/volumes/npm/letsencrypt
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/npm
  sudo chmod -R 775 /opt/volumes/npm

  docker compose up -d --build
}

cleanup_nginx() {
  cd "${path}/nginx"

  docker compose down
}

data_clean_nginx() {
  cd "${path}/nginx"

  docker compose down -v || true
  sudo rm -rf /opt/volumes/npm/data /opt/volumes/npm/letsencrypt
  sudo mkdir -p /opt/volumes/npm/data /opt/volumes/npm/letsencrypt
  sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/npm
  sudo chmod -R 775 /opt/volumes/npm

  echo "NGINX Proxy Manager data removed. The UI account will reset because NPM stores users inside /opt/volumes/npm/data."
}

reset_nginx() {
  cleanup_nginx
  setup_nginx
}

# ============================================================
# All Services
# ============================================================

setup_all() {
  setup_elastic_apm
  setup_postgres
  setup_mongodb
  setup_redis
  setup_kafka
  setup_rustfs
  setup_nginx
  show_status
}

cleanup_all() {
  cleanup_elastic_apm
  cleanup_postgres
  cleanup_mongodb
  cleanup_redis
  cleanup_kafka
  cleanup_rustfs
  cleanup_nginx
  show_status
}

data_clean_all() {
  data_clean_elastic_apm
  data_clean_postgres
  data_clean_mongodb
  data_clean_redis
  data_clean_kafka
  data_clean_rustfs
  data_clean_nginx
  show_status
}

reset_all() {
  cleanup_all
  setup_all
}

# ============================================================
# Usage
# ============================================================

show_usage() {
  echo "Usage:"
  echo "  ./manage-services.sh setup-all"
  echo "  ./manage-services.sh cleanup-all"
  echo "  ./manage-services.sh reset-all"
  echo "  ./manage-services.sh data-clean-all"
  echo "  ./manage-services.sh status"
  echo ""
  echo "Elastic APM:"
  echo "  ./manage-services.sh setup-elastic-apm"
  echo "  ./manage-services.sh cleanup-elastic-apm"
  echo "  ./manage-services.sh reset-elastic-apm"
  echo "  ./manage-services.sh data-clean-elastic-apm"
  echo ""
  echo "Postgres:"
  echo "  ./manage-services.sh setup-postgres"
  echo "  ./manage-services.sh cleanup-postgres"
  echo "  ./manage-services.sh reset-postgres"
  echo "  ./manage-services.sh data-clean-postgres"
  echo ""
  echo "MongoDB:"
  echo "  ./manage-services.sh setup-mongodb"
  echo "  ./manage-services.sh cleanup-mongodb"
  echo "  ./manage-services.sh reset-mongodb"
  echo "  ./manage-services.sh data-clean-mongodb"
  echo ""
  echo "Redis:"
  echo "  ./manage-services.sh setup-redis"
  echo "  ./manage-services.sh cleanup-redis"
  echo "  ./manage-services.sh reset-redis"
  echo "  ./manage-services.sh data-clean-redis"
  echo ""
  echo "Kafka:"
  echo "  ./manage-services.sh setup-kafka"
  echo "  ./manage-services.sh cleanup-kafka"
  echo "  ./manage-services.sh reset-kafka"
  echo "  ./manage-services.sh data-clean-kafka"
  echo ""
  echo "RustFS:"
  echo "  ./manage-services.sh setup-rustfs"
  echo "  ./manage-services.sh cleanup-rustfs"
  echo "  ./manage-services.sh reset-rustfs"
  echo "  ./manage-services.sh data-clean-rustfs"
  echo ""
  echo "NGINX Proxy Manager:"
  echo "  ./manage-services.sh setup-nginx"
  echo "  ./manage-services.sh cleanup-nginx"
  echo "  ./manage-services.sh reset-nginx"
  echo "  ./manage-services.sh data-clean-nginx"
}

# ============================================================
# Command Handler
# ============================================================

case "${1:-}" in
  setup-all) setup_all ;;
  cleanup-all) cleanup_all ;;
  reset-all) reset_all ;;
  data-clean-all) data_clean_all ;;
  status) show_status ;;

  setup-elastic-apm) setup_elastic_apm ;;
  cleanup-elastic-apm) cleanup_elastic_apm ;;
  reset-elastic-apm) reset_elastic_apm ;;
  data-clean-elastic-apm) data_clean_elastic_apm ;;

  setup-postgres) setup_postgres ;;
  cleanup-postgres) cleanup_postgres ;;
  reset-postgres) reset_postgres ;;
  data-clean-postgres) data_clean_postgres ;;

  setup-mongodb) setup_mongodb ;;
  cleanup-mongodb) cleanup_mongodb ;;
  reset-mongodb) reset_mongodb ;;
  data-clean-mongodb) data_clean_mongodb ;;

  setup-redis) setup_redis ;;
  cleanup-redis) cleanup_redis ;;
  reset-redis) reset_redis ;;
  data-clean-redis) data_clean_redis ;;

  setup-kafka) setup_kafka ;;
  cleanup-kafka) cleanup_kafka ;;
  reset-kafka) reset_kafka ;;
  data-clean-kafka) data_clean_kafka ;;

  setup-rustfs) setup_rustfs ;;
  cleanup-rustfs) cleanup_rustfs ;;
  reset-rustfs) reset_rustfs ;;
  data-clean-rustfs) data_clean_rustfs ;;

  setup-nginx) setup_nginx ;;
  cleanup-nginx) cleanup_nginx ;;
  reset-nginx) reset_nginx ;;
  data-clean-nginx) data_clean_nginx ;;

  *)
    show_usage
    exit 1
    ;;
esac
