# Elastic APM, Elasticsearch, Kibana, and ILM Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-elastic-apm
./manage-services.sh cleanup-elastic-apm
./manage-services.sh reset-elastic-apm
./manage-services.sh data-clean-elastic-apm
```

Before setup, create and edit credentials:

```bash
cp elastic-apm/.env.example elastic-apm/.env
nano elastic-apm/.env
```

Required values:

```bash
ELASTIC_PASSWORD=CHANGE_ME_ELASTIC_PASSWORD
KIBANA_PASSWORD=CHANGE_ME_KIBANA_PASSWORD
KIBANA_ENCRYPTION_KEY=CHANGE_ME_32_CHARACTER_KEY_HERE
APM_SECRET_TOKEN=CHANGE_ME_APM_SECRET_TOKEN
```

Generate secure values:

```bash
openssl rand -base64 32
openssl rand -base64 32 | head -c 32; echo
```

Ports:

```text
9200  Elasticsearch
5601  Kibana
8200  APM Server
```

Persistent data volume:

```text
/opt/volumes/elastic-apm/elasticsearch-data -> /usr/share/elasticsearch/data
```

`data-clean-elastic-apm` removes Elasticsearch data from `/opt/volumes/elastic-apm/elasticsearch-data` but does not change `elastic-apm/.env`.

## Direct Elastic Setup Script

You can still use the Elastic setup script directly from this directory:

```bash
chmod +x setup.sh
./setup.sh
./setup.sh --status
./setup.sh --stop
./setup.sh --clean
./setup.sh --clean-only
```

## ILM and Maintenance Scripts

The root setup command runs the 15-day ILM script automatically.

Manual run:

```bash
chmod +x ilm-15-day-retention.sh cleanup-old-indices.sh disk-usage-monitor.sh
./ilm-15-day-retention.sh
```
