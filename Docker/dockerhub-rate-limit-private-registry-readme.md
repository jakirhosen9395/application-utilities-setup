# Fix DockerHub Pull Rate Limit by Using a Private Registry

This guide explains how to fix Docker build failures caused by DockerHub unauthenticated pull rate limits by pulling the image from another network, pushing it to a private registry/Harbor, and then pulling it from the server.

## Problem

Docker build failed because DockerHub blocked the image pull:

```text
ERROR: failed to build: failed to solve: node:22-alpine: failed to resolve source metadata for docker.io/library/node:22-alpine
toomanyrequests: You have reached your unauthenticated pull rate limit.
```

This happened because the server reached DockerHub's unauthenticated pull limit.

## Solution overview

1. Use another machine/network that can pull the image from DockerHub.
2. Tag the image for the private registry/Harbor.
3. Push the image to the private registry.
4. On the server, log in to the private registry.
5. Pull the image from the private registry.
6. Retag it as the original image name expected by the Docker build.

---

## Example values

Change these example values based on your environment:

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_ALIAS="registry.local"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"
REGISTRY_USER="admin"
```

The private registry image will look like this:

```text
192.168.100.10/example-stage/node:22-alpine
```

The local image name expected by the Docker build will look like this:

```text
node:22-alpine
```

---

# Part 1: Push image to private registry/Harbor from any machine

Run these steps on the machine where DockerHub pull works.

## 1. Configure Docker insecure registry

Use this only for a trusted private/internal registry.

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_ALIAS="registry.local"

sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}",
    "${REGISTRY_ALIAS}"
  ]
}
EOF
```

This creates or updates Docker's daemon configuration so Docker can communicate with the private registry even if the registry uses an internal/self-signed certificate.

## 2. Restart Docker

```bash
sudo systemctl restart docker
```

This reloads Docker with the new insecure registry configuration.

## 3. Log in to the private registry

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_USER="admin"

read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u "$REGISTRY_USER" --password-stdin
unset REG_PASS
```

When you see this prompt, type the registry password and press Enter:

```text
Registry password:
```

The password will not be shown while typing.

## 4. Pull the image from DockerHub

```bash
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"

sudo docker pull "${IMAGE_NAME}:${IMAGE_TAG}"
```

Example:

```bash
sudo docker pull node:22-alpine
```

## 5. Tag the image for the private registry

```bash
REGISTRY_HOST="192.168.100.10"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"

sudo docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
```

Example:

```bash
sudo docker tag node:22-alpine 192.168.100.10/example-stage/node:22-alpine
```

## 6. Push the image to private registry/Harbor

```bash
sudo docker push "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
```

Example:

```bash
sudo docker push 192.168.100.10/example-stage/node:22-alpine
```

---

# Part 2: Pull image from private registry on another server

Run these steps on the server where DockerHub pull was failing.

## 1. Configure Docker insecure registry

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_ALIAS="registry.local"

sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}",
    "${REGISTRY_ALIAS}"
  ]
}
EOF
```

## 2. Restart Docker

```bash
sudo systemctl restart docker
```

## 3. Log in to the private registry

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_USER="admin"

read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u "$REGISTRY_USER" --password-stdin
unset REG_PASS
```

When prompted, enter the registry password:

```text
Registry password:
```

## 4. Pull the image from private registry

Use the full private registry image path.

```bash
REGISTRY_HOST="192.168.100.10"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"

sudo docker pull "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
```

Example:

```bash
sudo docker pull 192.168.100.10/example-stage/node:22-alpine
```

Do not pull without the registry host, for example:

```bash
docker pull example-stage/node:22-alpine
```

That will try to pull from DockerHub instead of your private registry.

## 5. Retag the image as the original DockerHub image name

```bash
sudo docker tag "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:${IMAGE_TAG}"
```

Example:

```bash
sudo docker tag 192.168.100.10/example-stage/node:22-alpine node:22-alpine
```

This converts:

```text
192.168.100.10/example-stage/node:22-alpine
```

into:

```text
node:22-alpine
```

Now your Docker build can use:

```text
FROM node:22-alpine
```

without pulling directly from DockerHub.

## 6. Verify the image

```bash
sudo docker images | grep "${IMAGE_NAME}"
```

Expected result should include both images:

```text
192.168.100.10/example-stage/node    22-alpine
node                                 22-alpine
```

---

## Short command summary

### Push machine

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_ALIAS="registry.local"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"
REGISTRY_USER="admin"

sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}",
    "${REGISTRY_ALIAS}"
  ]
}
EOF

sudo systemctl restart docker

read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u "$REGISTRY_USER" --password-stdin
unset REG_PASS

sudo docker pull "${IMAGE_NAME}:${IMAGE_TAG}"
sudo docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
sudo docker push "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
```

### Server machine

```bash
REGISTRY_HOST="192.168.100.10"
REGISTRY_ALIAS="registry.local"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"
REGISTRY_USER="admin"

sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}",
    "${REGISTRY_ALIAS}"
  ]
}
EOF

sudo systemctl restart docker

read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u "$REGISTRY_USER" --password-stdin
unset REG_PASS

sudo docker pull "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
sudo docker tag "${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:${IMAGE_TAG}"

sudo docker images | grep "${IMAGE_NAME}"
```

---

## Notes

- Always use the full image path when pulling from the private registry:

```text
<registry-host>/<repo-name>/<image-name>:<tag>
```

- Example:

```text
192.168.100.10/example-stage/node:22-alpine
```

- If you pull only `example-stage/node:22-alpine`, Docker will try DockerHub, not your private registry.
- This workaround avoids DockerHub rate-limit errors by using your private registry as an internal image source.
- If a real registry password was pasted into terminal history or chat, rotate/change the password.