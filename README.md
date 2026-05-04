```bash
# -------------------------------------------------
# DOCKER : Host prerequisites (run on host before starting)
# -------------------------------------------------  
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

```bash
# -------------------------------------------------
# APM : Host prerequisites (run on host before starting)
# -------------------------------------------------  

# Clone and navigate to the project
git clone https://github.com/siyamsarker/elastic-apm-quickstart.git
cd "elastic-apm-quickstart"

# Create environment file from example
cp .env.example .env


# Generate Elasticsearch password
openssl rand -base64 24

# Generate Kibana password
openssl rand -base64 24

# Generate Kibana encryption key (exactly 32 characters)
openssl rand -base64 32 | head -c 32

# Generate APM secret token
openssl rand -base64 24

# Edit .env file and set your passwords
# IMPORTANT: Replace all 'changeme' values with strong, unique passwords
nano .env  # or use your preferred editor


# Make setup script executable
chmod +x setup.sh

# 🚀 Normal setup
./setup.sh

# 🧹 Clean installation (removes existing data and re-setup)
./setup.sh --clean

# 🗑️  Remove all containers and volumes (no re-setup)
./setup.sh --clean-only

# 📊 Check service status
./setup.sh --status

# 🛑 Stop all services
./setup.sh --stop

# ❓ Show help
./setup.sh --help


# Set executable permissions for maintenance scripts
chmod +x ilm-15-day-retention.sh cleanup-old-indices.sh disk-usage-monitor.sh

# Run the ILM setup script
./ilm-15-day-retention.sh
```

```bash
# -------------------------------------------------
# POSTGRES : Host prerequisites (run on host before starting)
# -------------------------------------------------  
sudo mkdir -p /opt/volumes/postgres/data && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/postgres && sudo chmod -R 775 /opt/volumes/postgres && docker compose up -d --build
docker logs -f postgres
```


```bash
# -------------------------------------------------
# MONGODB : Host prerequisites (run on host before starting)
# -------------------------------------------------  
sudo mkdir -p /opt/volumes/mongodb/data && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/mongodb && sudo chmod -R 775 /opt/volumes/mongodb && docker compose up -d --build
docker logs -f mongodb
```


```bash
# -------------------------------------------------
# REDIS : Host prerequisites (run on host before starting)
# -------------------------------------------------   
sudo mkdir -p /opt/volumes/redis/data && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/redis && sudo chmod -R 775 /opt/volumes/redis && docker compose up -d --build
docker logs -f redis
```

```bash
# -------------------------------------------------
# KAFKA : Host prerequisites (run on host before starting)
# -------------------------------------------------  
sudo mkdir -p /opt/volumes/kafka/data && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/kafka && sudo chmod -R 775 /opt/volumes/kafka && docker compose up -d --build
docker logs -f kafka
```

```bash
# -------------------------------------------------
# RUSTFS : Host prerequisites (run on host before starting)
# ------------------------------------------------- 
sudo mkdir -p /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs && sudo chmod -R 775 /opt/volumes/rustfs/data/rustfs-data /opt/volumes/rustfs/data/rustfs-logs && docker compose up -d --build
docker logs -f rustfs
```


```bash
# -------------------------------------------------
# NGINX : Host prerequisites (run on host before starting)
# ------------------------------------------------- 
sudo mkdir -p /opt/volumes/npm/{data,letsencrypt} && sudo chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" /opt/volumes/npm && sudo chmod -R 775 /opt/volumes/npm && docker compose up -d
```
