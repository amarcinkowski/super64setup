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
