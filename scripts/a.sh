#!/bin/bash

# Ustawienie kolorów dla lepszej czytelności
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🚀 Tworzenie struktury katalogów dla GitHub Actions..."
mkdir -p .github/workflows
echo -e "${GREEN}✔ Katalog .github/workflows został utworzony.${NC}"

# --- Tworzenie pliku Dockerfile ---
echo "📄 Tworzenie przykładowego pliku Dockerfile..."
cat <<'EOF' > Dockerfile
# Użyj oficjalnego obrazu Node.js jako bazy
FROM node:20-alpine

# Ustaw katalog roboczy w kontenerze
WORKDIR /usr/src/app

# Skopiuj pliki package.json i package-lock.json
COPY package*.json ./

# Zainstaluj zależności aplikacji
RUN npm install

# Skopiuj resztę plików aplikacji do katalogu roboczego
COPY . .

# Ujawnij port, na którym działa aplikacja
EXPOSE 3000

# Polecenie do uruchomienia aplikacji
CMD [ "node", "server.js" ]
EOF
echo -e "${GREEN}✔ Plik Dockerfile został utworzony.${NC}"

# --- Tworzenie pliku workflow ---
echo "⚙️ Tworzenie pliku workflow 'docker-publish.yml'..."
cat <<'EOF' > .github/workflows/docker-publish.yml
name: Build and Push Docker Image

# Ten workflow uruchomi się, gdy commit zostanie wypchnięty do repozytorium
# ale TYLKO wtedy, gdy zmiany dotyczą pliku Dockerfile.
on:
  push:
    branches:
      - '**' # Uruchom dla każdej gałęzi
    paths:
      - 'Dockerfile' # Tylko jeśli Dockerfile został zmieniony

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write # Uprawnienie do zapisu w GitHub Packages (Container Registry)

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Log in to the GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            # Tag z nazwą brancha (np. "feature-x", "develop")
            type=ref,event=branch
            # Tag "latest" tylko dla brancha "main"
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
EOF
echo -e "${GREEN}✔ Plik .github/workflows/docker-publish.yml został utworzony.${NC}"

echo -e "\n🎉 ${GREEN}Konfiguracja zakończona sukcesem!${NC}"
echo "Teraz dodaj, skomituj i wypchnij pliki do swojego repozytorium na GitHub."

