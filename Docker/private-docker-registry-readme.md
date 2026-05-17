# Private Docker Registry Image Pull and Retag Guide

This README explains how to configure Docker for a private registry, log in securely, pull an image, and retag it locally.

The IP address, repository name, image name, and image tag are written as **examples**. Replace them with your actual values before running the commands.

---

## Example values

Change these values as needed:

```bash
REGISTRY_HOST="192.168.100.10"          # Example registry IP or hostname
REPO_NAME="example-repo"                # Example repository/project name
IMAGE_NAME="example-image"              # Example image name
IMAGE_TAG="latest"                      # Example image tag
LOCAL_IMAGE_NAME="example-image"        # Example local image name
```

Example remote image format:

```text
<REGISTRY_HOST>/<REPO_NAME>/<IMAGE_NAME>:<IMAGE_TAG>
```

Example:

```text
192.168.100.10/example-repo/example-image:latest
```

Example local image format:

```text
<LOCAL_IMAGE_NAME>:<IMAGE_TAG>
```

Example:

```text
example-image:latest
```

---

## 1. Set variables

Update these example values first:

```bash
REGISTRY_HOST="192.168.100.10"
REPO_NAME="example-repo"
IMAGE_NAME="example-image"
IMAGE_TAG="latest"
LOCAL_IMAGE_NAME="example-image"

REMOTE_IMAGE="${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
LOCAL_IMAGE="${LOCAL_IMAGE_NAME}:${IMAGE_TAG}"
```

---

## 2. Configure Docker insecure registry

Use this only for a trusted private/internal registry.

```bash
sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}"
  ]
}
EOF

sudo systemctl restart docker
```

---

## 3. Log in to the private registry

Do not paste the password directly into the command. Use a hidden password prompt:

```bash
read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u admin --password-stdin
unset REG_PASS
```

---

## 4. Pull the image

```bash
sudo docker pull "$REMOTE_IMAGE"
```

Example:

```bash
sudo docker pull 192.168.100.10/example-repo/example-image:latest
```

---

## 5. Retag the image locally

```bash
sudo docker tag "$REMOTE_IMAGE" "$LOCAL_IMAGE"
```

Example:

```bash
sudo docker tag 192.168.100.10/example-repo/example-image:latest example-image:latest
```

This converts the remote registry image:

```text
192.168.100.10/example-repo/example-image:latest
```

into the local image tag:

```text
example-image:latest
```

---

## 6. Verify the image

```bash
sudo docker images | grep "$LOCAL_IMAGE_NAME"
```

Example:

```bash
sudo docker images | grep example-image
```

---

## Full example command block

Change the example values before running:

```bash
REGISTRY_HOST="192.168.100.10"
REPO_NAME="example-repo"
IMAGE_NAME="example-image"
IMAGE_TAG="latest"
LOCAL_IMAGE_NAME="example-image"

REMOTE_IMAGE="${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
LOCAL_IMAGE="${LOCAL_IMAGE_NAME}:${IMAGE_TAG}"

sudo mkdir -p /etc/docker

sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true

sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "insecure-registries": [
    "${REGISTRY_HOST}"
  ]
}
EOF

sudo systemctl restart docker

read -rsp 'Registry password: ' REG_PASS; echo
printf '%s' "$REG_PASS" | sudo docker login "$REGISTRY_HOST" -u admin --password-stdin
unset REG_PASS

sudo docker pull "$REMOTE_IMAGE"

sudo docker tag "$REMOTE_IMAGE" "$LOCAL_IMAGE"

sudo docker images | grep "$LOCAL_IMAGE_NAME"
```

---

## Example for Node Alpine image

This is only an example. Replace the values if your registry, repo, or image is different.

```bash
REGISTRY_HOST="192.168.100.10"
REPO_NAME="example-stage"
IMAGE_NAME="node"
IMAGE_TAG="22-alpine"
LOCAL_IMAGE_NAME="node"

REMOTE_IMAGE="${REGISTRY_HOST}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
LOCAL_IMAGE="${LOCAL_IMAGE_NAME}:${IMAGE_TAG}"

sudo docker pull "$REMOTE_IMAGE"
sudo docker tag "$REMOTE_IMAGE" "$LOCAL_IMAGE"
sudo docker images | grep "$LOCAL_IMAGE_NAME"
```

This converts:

```text
192.168.100.10/example-stage/node:22-alpine
```

into:

```text
node:22-alpine
```

---

## Troubleshooting

### Error: tag does not exist

If you see:

```text
tag does not exist
```

The image tag does not exist locally. Pull the image first or check the exact image name:

```bash
sudo docker images
```

---

### Error: no such image

If you see:

```text
No such image
```

You may have missed the image tag.

Wrong:

```bash
sudo docker tag 192.168.100.10/example-repo/example-image example-image:latest
```

Correct:

```bash
sudo docker tag 192.168.100.10/example-repo/example-image:latest example-image:latest
```

---

### Error: TLS certificate validation failed

If you see a TLS certificate error, confirm the registry is listed under Docker insecure registries:

```bash
docker info | grep -A20 'Insecure Registries'
```

If your registry is missing, update `/etc/docker/daemon.json` and restart Docker.

---

## Security note

If a real registry password was pasted directly into the terminal or chat, rotate/change that password.