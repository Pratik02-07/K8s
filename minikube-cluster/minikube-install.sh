
#!/usr/bin/env bash

set -Eeuo pipefail

# Install Docker, Minikube, and kubectl on Ubuntu/Debian.
# Run this script as a normal user with sudo privileges.

echo "Starting installation of Docker, Minikube, and kubectl..."

# ----------------------------
# 1. Check architecture
# ----------------------------
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64)
    MINIKUBE_ARCH="amd64"
    KUBECTL_ARCH="amd64"
    ;;
  aarch64|arm64)
    MINIKUBE_ARCH="arm64"
    KUBECTL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

# ----------------------------
# 2. Install dependencies
# ----------------------------
echo "Installing required dependencies..."
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  conntrack \
  iptables

# ----------------------------
# 3. Install Docker
# ----------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker..."
  sudo apt-get install -y docker.io
else
  echo "Docker is already installed."
fi

# Enable Docker service when systemd is available.
if command -v systemctl >/dev/null 2>&1; then
  if systemctl is-active --quiet docker; then
    echo "Docker service is already running."
  elif sudo systemctl start docker; then
    echo "Docker service started."
  else
    echo "Could not start Docker with systemctl."
    echo "Check your Docker or WSL2 service configuration."
  fi
fi

# Add the current user to the Docker group if needed.
if ! getent group docker >/dev/null 2>&1; then
  sudo groupadd docker
fi

if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  sudo usermod -aG docker "$USER"
  echo "Added $USER to the docker group."
  echo "Log out and back in, or restart your WSL terminal, to apply this change."
else
  echo "User is already in the docker group."
fi

# ----------------------------
# 4. Install Minikube
# ----------------------------
if ! command -v minikube >/dev/null 2>&1; then
  echo "Installing Minikube..."

  curl -fL --retry 3 \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${MINIKUBE_ARCH}" \
    -o /tmp/minikube

  chmod +x /tmp/minikube
  sudo install /tmp/minikube /usr/local/bin/minikube
  rm -f /tmp/minikube
else
  echo "Minikube is already installed."
fi

# ----------------------------
# 5. Install kubectl
# ----------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo "Installing kubectl..."

  VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"

  curl -fL --retry 3 \
    "https://dl.k8s.io/release/${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" \
    -o /tmp/kubectl

  chmod +x /tmp/kubectl
  sudo install /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
else
  echo "kubectl is already installed."
fi

# ----------------------------
# 6. Verify installations
# ----------------------------
echo
echo "Installed versions:"
docker --version
minikube version
kubectl version --client

echo
echo "Installation complete!"
echo "Next: verify Docker access, then start Minikube."
