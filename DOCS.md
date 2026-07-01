# Hexesoft Bridge Mitsubishi

Ponte tra il controller **Mitsubishi AE-200** (sistemi VRF / City Multi e macchine idroniche) e **Home Assistant**, via **MQTT**.
Porta in Home Assistant — in modo automatico — i condizionatori (split) e le macchine ad acqua collegate all'AE-200,
e può integrarsi con i termostati **BTicino** per gestire il clima in modo coordinato.

## Cosa fa

Il bridge si collega all'AE-200 (via WebSocket) e:

- **legge ciclicamente** lo stato di ogni macchina (acceso/spento, modo, temperatura ambiente, setpoint, ventola);
- **pubblica i dispositivi da soli** in Home Assistant tramite MQTT Discovery (niente YAML);
- **traduce i comandi** dati da Home Assistant (accendi, cambia modo, imposta temperatura/ventola) in istruzioni per l'AE-200;
- **rimuove da solo** da Home Assistant le macchine che togli dalla configurazione;
- **si riconnette da solo** sia all'AE-200 sia al broker MQTT in caso di caduta.

A scelta, funziona in modo **autonomo** (ogni macchina è un clima a sé in HA) oppure **integrato** con i termostati BTicino.

## Funzionalità

- **Discovery automatica e pulizia**: pubblica gli split e gli idronici configurati e rimuove le entità non più presenti.
- **Lettura in tempo reale**: interroga l'AE-200 a intervalli regolari e aggiorna Home Assistant.
- **Controllo completo dello split**: acceso/spento, modi (riscaldamento, raffrescamento, deumidificazione, ventola, automatico), setpoint e **velocità ventola** (auto / bassa / media / alta).
- **Macchine idroniche**: boiler acqua sanitaria e pavimento radiante, con limiti di temperatura adeguati al tipo.
- **Due modalità di lavoro** (Diretta / Integrata, vedi sotto).
- **Logica Ibrida (boost)**: in modalità integrata accende il VRF in aiuto al termostato BTicino quando la stanza è troppo lontana dal setpoint (parametri *delta*).
- **Riconnessione automatica** e stato Online/Offline del bridge.
- **Pulsante "Scansiona rete"** per forzare una lettura immediata di tutte le macchine.
- **Log leggibile** a livelli configurabili (`info`, `debug`, `warning`, `error`).

## Le due modalità di lavoro

### A. Modalità DIRETTA (standard)
Ogni macchina Mitsubishi appare in Home Assistant come un **clima indipendente**.
- **Cosa vedi**: una scheda "Clima" per ogni split / idronico.
- **Cosa puoi fare**: accendere, spegnere, cambiare modo, regolare temperatura e ventola, come col telecomando originale.

### B. Modalità INTEGRATA (con i termostati BTicino)
Gli split Mitsubishi **spariscono** da Home Assistant: il comando passa ai **termostati BTicino** (serve anche il programma *Hexesoft Bridge Bticino*).
- **Cosa vedi**: usi solo i termostati BTicino, a muro o in app.
- **Cosa succede**: il bridge osserva i termostati BTicino e, quando la stanza è troppo lontana dal setpoint (oltre il *delta*), accende automaticamente il VRF per dare una mano e raggiungere prima la temperatura.
- **Parametro fondamentale**: per ogni split va indicata la **zona BTicino** (`bticino_zone`) a cui è abbinato.

## L'effetto "Boost" (parametri Delta)

In modalità integrata decidi quanto dev'essere "aggressivo" l'intervento del VRF tramite i *delta*:

- **`heating_boost_delta` (inverno)**: scostamento minimo per accendere in caldo.
  *Es.* `3.0` → il VRF parte solo se la stanza è più fredda di 3 °C rispetto al setpoint del termostato.
- **`cooling_boost_delta` (estate)**: scostamento minimo per accendere in freddo.
  *Es.* `0.0` → il VRF parte appena la stanza supera il setpoint.

## Come funziona (in breve)

Il bridge apre un **tunnel WebSocket** verso l'AE-200 (sotto-protocollo `b_xmlproc`) e scambia messaggi **XML** per leggere lo stato e inviare i comandi. Interroga le macchine una alla volta a intervalli regolari (polling) e pubblica gli stati su MQTT con flag *retain*, così Home Assistant li ritrova anche dopo un riavvio. In modalità integrata ascolta in più i termostati BTicino sul broker condiviso.

## Requisiti

- Un **controller Mitsubishi AE-200** raggiungibile in rete (accesso `b_xmlproc` abilitato).
- Un **broker MQTT** (es. Mosquitto) raggiungibile dal bridge e da Home Assistant.
- **Home Assistant** con l'integrazione **MQTT** attiva.
- Per la modalità integrata: il programma **Hexesoft Bridge Bticino** attivo sullo stesso broker.

## Configurazione

### Impostazioni generali (`mitsubishi`)
- **`host`**: indirizzo IP dell'AE-200.
- **`polling_interval`**: secondi tra una lettura e l'altra (minimo 5).
- **`operating_mode`**: `"standard"` (diretta) oppure `"integrated"`.
- **`bticino_base_topic`**: topic base del bridge BTicino (modalità integrata), es. `"bticino_bridge"`.
- **`heating_boost_delta`** / **`cooling_boost_delta`**: i delta del boost (vedi sopra).

### Broker (`mqtt`)
- **`host`** / **`port`** / **`username`** / **`password`**: connessione al broker.
- **`base_topic`**: radice dei messaggi MQTT (es. `"mitsubishi_bridge"`).

### Macchine
Per ogni macchina (split o idronico):
- **`id`**: numero della macchina sul controller AE-200 (es. `"01"`, `"03"`).
- **`name`**: nome della macchina (es. `"Camera"`, `"Salone"`).
- **`bticino_zone`** *(solo integrata, split)*: numero della zona del termostato BTicino abbinato.
- **`supports_dry`** *(split)*: `true` se la macchina deumidifica, altrimenti `false`.
- **`type`** *(idronico)*: `"hot_water"` per il boiler acqua sanitaria, altrimenti pavimento radiante (cambia modello e limiti di temperatura).

Limiti di temperatura predefiniti: split 16-30 °C, acqua sanitaria 30-70 °C, pavimento radiante 20-40 °C (passo 0,5 °C).

### Esempio

```json
{
  "mitsubishi": {
    "host": "192.168.10.38",
    "polling_interval": 10,
    "operating_mode": "integrated",
    "bticino_base_topic": "bticino_bridge",
    "heating_boost_delta": 3.0,
    "cooling_boost_delta": 0.0
  },
  "mqtt": {
    "host": "192.168.10.34",
    "port": 1883,
    "base_topic": "mitsubishi_bridge"
  },
  "air_conditioners": {
    "devices": [
      { "id": "15", "name": "Sala nord", "bticino_zone": "60", "supports_dry": true }
    ]
  },
  "hydronics": {
    "devices": [
      { "id": "01", "name": "Acqua sanitaria", "type": "hot_water" }
    ]
  }
}
```