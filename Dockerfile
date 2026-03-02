# Usiamo Debian Slim
FROM debian:bookworm-slim

# Installiamo i componenti minimi richiesti da .NET
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia solo il tuo eseguibile (appsettings non lo pubblichiamo più)
COPY Hexesoft-Mitsubishi .

# Diamo i permessi di esecuzione direttamente al programma
RUN chmod +x /app/Hexesoft-Mitsubishi

# Avviamo il programma nativamente 
CMD [ "/app/Hexesoft-Mitsubishi" ]