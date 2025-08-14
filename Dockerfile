# Krok 1: Wybierz oficjalny, lekki obraz Javy jako podstawę
# Używamy konkretnej wersji, aby zapewnić spójność środowiska.
FROM openjdk:17-jdk-slim

# Krok 2: Ustaw zmienne środowiskowe dla wersji Kick Assemblera
# Ułatwia to aktualizację w przyszłości - wystarczy zmienić numer wersji.
ENV KICKASS_VERSION=5.25
ENV KICKASS_HOME=/opt/kickass

# Krok 3: Zainstaluj potrzebne narzędzia i posprzątaj
# 'wget' jest potrzebny do pobrania archiwum, a 'unzip' do jego rozpakowania.
# Po instalacji czyścimy cache, aby zmniejszyć rozmiar finalnego obrazu.
RUN apt-get update && \
    apt-get install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Krok 4: Pobierz, rozpakuj Kick Assembler i usuń plik archiwum
RUN wget http://theweb.dk/KickAssembler/KickAss.zip -O /tmp/kickass.zip && \
    unzip /tmp/kickass.zip -d ${KICKASS_HOME} && \
    rm /tmp/kickass.zip

# Krok 5: Utwórz skrypt ułatwiający uruchamianie asemblera
# Dzięki temu zamiast pisać 'java -jar /opt/kickass/KickAss.jar', będziesz mógł używać prostej komendy 'kickass'.
RUN echo '#!/bin/sh' > /usr/local/bin/kickass && \
    echo 'java -jar ${KICKASS_HOME}/KickAss.jar "$@"' >> /usr/local/bin/kickass && \
    chmod +x /usr/local/bin/kickass

# Krok 6: Ustaw domyślny katalog roboczy
# To w tym miejscu będą znajdować się Twoje pliki źródłowe, gdy podmontujesz je do kontenera.
WORKDIR /app

# Krok 7: Zdefiniuj punkt wejścia kontenera
# Ustawia nasz skrypt 'kickass' jako główną komendę wykonywaną przez kontener.
ENTRYPOINT ["kickass"]

# Krok 8: Zdefiniuj domyślną komendę
# Jeśli uruchomisz kontener bez dodatkowych argumentów, wyświetli on pomoc Kick Assemblera.
# To dobry sposób, aby sprawdzić, czy wszystko działa poprawnie.
CMD ["--help"]

