# MCDReforged (MCDR) Docker Setup

This repository contains a Docker setup for running [MCDReforged](https://mcdreforged.com/en) with a Minecraft server.

---

## Repository Contents

- **`Dockerfile`**<br>
  Builds the MCDReforged image with:
  - Python 3.12
  - Java 25.0.1
  - MCDReforged
  - Some Python dependencies commonly used by MCDR plugins

- **`docker-compose.yml`**<br>
  Defines the MCDR service, publishes the required ports (Minecraft), and mounts persistent data.

- **`start_mcdr.sh`**<br>
  Container entrypoint script that:
  - Creates and uses a persistent Python virtual environment in `/data/venv`
  - Installs/updates MCDReforged inside the venv
  - Installs extra plugin dependencies if they exist in `requirements-extra.txt`
  - Runs `mcdreforged init` on first startup
  - Starts MCDReforged in a container-safe way otherwise

- **`requirements-extra.txt`**
  - A persistent list of plugin-specific Python dependencies that are not baked into the base image.
  - Can be modified based on your MCDR plugins.
  - This file is tracked in Git so deployments are reproducible.

---

# Directory layout at runtime

When running, the container expects a persistent `data/` directory mounted to `/data`:
```graphql
data/
├─ config/          # MCDReforged and plugin configs
├─ plugins/         # MCDR plugins (.mcdr)
├─ server/          # Minecraft server files
├─ venv/            # Persistent Python virtual environment
└─ requirements-extra.txt
```
Only `data/` is persisted. The container itself can be safely recreated.

---

## How to use

### 1. Clone the repository
```bash
git clone <this-repo>
cd <this-repo>
```

### 2. Create the data directory
```bash
mkdir -p data
```
(Optional) Create an empty `data/requirements-extra.txt` if it doesn't exist.

### 3. Build and start
```bash
docker compose up -d --build
```
On first startup, MCDReforged will automatically initialize its directory structure.

---

## Managing plugins and dependencies

- Drop plugins into:
  ```bash
  data/plugins/
  ```
  
- If a plugin fails to load due to a missing Python dependency:
  1. Add the dependency name to `/data/requirements-extra.txt`
  2. Install it into the running container:
     ```bash
     docker exec -it <container-name> bash -lc "source /data/venv/bin/activate && pip install -r /data/requirements-extra.txt"
     ```
  3. Reload plugins in-game:
     ```
     !!MCDR reload
     ```
     
This allows for hot-reloading plugins without rebuilding the image.

---

## Requirements

- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- A [Minecraft server JAR](https://www.minecraft.net/en-us/download/server) placed in `data/server/`

---
