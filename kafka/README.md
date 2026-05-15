# Kafka Utility

Use the root script from the project root directory.

```bash
./manage-services.sh setup-kafka
./manage-services.sh cleanup-kafka
./manage-services.sh reset-kafka
./manage-services.sh data-clean-kafka
```

Before setup, create and edit configuration:

```bash
cp kafka/.env.example kafka/.env
nano kafka/.env
```

Set this value to the IP/domain your applications use to connect to Kafka:

```bash
KAFKA_EXTERNAL_HOST=YOUR_SERVER_IP_OR_DOMAIN
```

Persistent data volume:

```text
/opt/volumes/kafka/data -> /var/lib/kafka/data
```

`data-clean-kafka` removes Kafka data from `/opt/volumes/kafka/data` but does not change `kafka/.env`.
