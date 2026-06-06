# Hexesoft Mitsubishi Bridge

> 🇮🇹 **Italiano** (sotto) · 🇬🇧 [English version below](#-english)

---

# 🇮🇹 Guida all'Uso

Questo programma è il "cervello" che mette in comunicazione il tuo sistema di climatizzazione **Mitsubishi** (tramite i controller **AE‑200 / EW‑50 / AG‑150A**) con **Home Assistant**, usando **MQTT**.

Legge in tempo reale lo stato di ogni macchina (condizionatori/fan coil e sistemi idronici come pompe di calore, boiler sanitari e pavimenti radianti) e lo pubblica su MQTT, da cui Home Assistant crea automaticamente i termostati (auto‑discovery). Allo stesso modo inoltra alle macchine i comandi che dai da Home Assistant.

## Le due modalità di funzionamento

Il programma può lavorare in due modi, scelti col parametro `operating_mode`:

- **`standard`** — Vedi in Home Assistant **tutti** i dispositivi (condizionatori e idronici) con tutte le proprietà: temperatura, modalità (caldo/freddo/auto/deumidifica/ventola), velocità della ventola.
- **`integrated`** — Pensato per chi usa anche i **termostati BTicino**. I **condizionatori vengono nascosti** in Home Assistant, perché a comandarli ci pensano i termostati BTicino. Il bridge:
  - **ascolta** i termostati BTicino (via MQTT) e accende/spegne i fan coil di conseguenza;
  - **ripubblica** lo stato reale di ogni fan coil su MQTT, indicizzato per **zona BTicino**, così il bridge BTicino può mostrarlo nei suoi termostati;
  - gli **idronici restano visibili** anche in questa modalità.

### Il "boost" in modalità integrata
In `integrated` puoi impostare un margine che ritarda l'accensione dei fan coil:
- **`heating_boost_delta`** (riscaldamento): il fan coil parte **solo** quando la stanza è di questi gradi **sotto** il setpoint. Esempio con `3.0`: se il setpoint è 21°C, il fan coil interviene solo sotto i 18°C, **a supporto** dell'impianto radiante (che da solo ci metterebbe più tempo).
- **`cooling_boost_delta`** (raffrescamento): il fan coil parte quando la stanza supera il setpoint di questi gradi. Con `0.0` parte appena la temperatura supera il setpoint.

Per evitare continui accendi/spegni attorno al setpoint, il programma applica una piccola **isteresi** (≈0,3°C): la macchina si spegne solo dopo aver oltrepassato il setpoint di quel margine.

## Requisiti

- Un controller Mitsubishi **AE‑200 / EW‑50 / AG‑150A** raggiungibile in rete (con l'interfaccia che comunica via WebSocket).
- Un **broker MQTT** (es. Mosquitto).
- **Home Assistant** con l'integrazione **MQTT** attiva (l'auto‑discovery è di serie).

## Installazione

Il programma cerca la configurazione in due posti, in ordine:
1. `/data/options.json` → se presente (tipico quando gira come **Add‑on di Home Assistant**).
2. `appsettings.json` → nella cartella del programma (uso **standalone**, es. su Windows/Linux).

## Configurazione

La configurazione è divisa in blocchi. Esempio completo e funzionante:

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
    "username": "system",
    "password": "la-tua-password",
    "base_topic": "mitsubishi_bridge",
    "discovery_prefix": "homeassistant"
  },
  "advanced": {
    "log_level": "info"
  },
  "air_conditioners": {
    "devices": [
      { "id": "16", "name": "1 sala sud VRF", "bticino_zone": "61", "supports_dry": false }
    ]
  },
  "hydronics": {
    "devices": [
      { "id": "01", "name": "Acqua calda sanitaria", "type": "HOT_WATER" },
      { "id": "02", "name": "Riscaldamento radiante", "type": "HEATING" }
    ]
  }
}
```

### Blocco `mitsubishi`
| Parametro | Significato |
|---|---|
| `host` | Indirizzo IP del controller AE‑200/EW‑50/AG‑150A. |
| `polling_interval` | Ogni quanti **secondi** rileggere lo stato (minimo 5). |
| `operating_mode` | `standard` (tutto visibile) oppure `integrated` (vedi sopra). |
| `bticino_base_topic` | Solo per `integrated`: il topic base del BTicino bridge da ascoltare (di solito `bticino_bridge`). |
| `heating_boost_delta` | Solo `integrated`: margine °C sotto setpoint per far partire il fan coil in caldo. |
| `cooling_boost_delta` | Solo `integrated`: margine °C sopra setpoint per far partire il fan coil in freddo. |

### Blocco `mqtt`
| Parametro | Significato |
|---|---|
| `host` / `port` | Indirizzo e porta del broker MQTT (porta tipica `1883`). |
| `username` / `password` | Credenziali MQTT (lascia vuoto per accesso anonimo). |
| `base_topic` | Radice dei topic di questo programma (di default `mitsubishi_bridge`). |
| `discovery_prefix` | Prefisso dell'auto‑discovery di Home Assistant: lasciare `homeassistant`. |

### Blocco `advanced`
| Parametro | Significato |
|---|---|
| `log_level` | Dettaglio dei log: `debug`, `info`, `warning`, `error`. |

### Blocco `air_conditioners` (condizionatori / fan coil)
Ogni dispositivo dentro `devices`:
| Campo | Significato |
|---|---|
| `id` | **Indirizzo M‑Net** della macchina sul controller (es. `"16"`). |
| `name` | Nome descrittivo mostrato in Home Assistant. |
| `bticino_zone` | Solo `integrated`: numero della **zona del termostato BTicino** abbinato a questa macchina. È la "chiave" che collega i due sistemi. |
| `supports_dry` | `true` se la macchina supporta la deumidificazione (aggiunge la modalità "dry"). |

### Blocco `hydronics` (pompe di calore / boiler / radiante)
| Campo | Significato |
|---|---|
| `id` | Indirizzo M‑Net della macchina. |
| `name` | Nome descrittivo. |
| `type` | `HOT_WATER` (boiler acqua sanitaria, 30–70°C) oppure `HEATING` (pavimento radiante, 20–40°C). |

> **Come trovo l'`id` (indirizzo M‑Net)?** È il numero con cui la macchina è censita nel controller Mitsubishi (lo stesso che vedi nell'interfaccia web del AE‑200). Va scritto come stringa, anche con lo zero davanti (es. `"03"`).

## Uso con i termostati BTicino (modalità integrata)

1. Imposta `"operating_mode": "integrated"`.
2. Per ogni condizionatore, in `bticino_zone` metti il **numero di zona** del termostato BTicino corrispondente.
3. **Sul termostato BTicino**: nel parametro dove normalmente si imposta il numero dell'**elettrovalvola**, va impostato il valore **Gateway**. In questo modo il termostato sa che per il freddo (e/o il caldo) deve passare dal gateway VRF, non da una valvola.
4. Assicurati che il **BTicino bridge sia in funzione**: è lui che pubblica i termostati in Home Assistant, mentre questo programma fornisce lo stato reale delle macchine.

In questa modalità i condizionatori **non** compaiono come entità separate in Home Assistant: i loro stati vengono pubblicati su `mitsubishi_bridge/climate/<zona>/…` e li legge il BTicino bridge per mostrare temperatura, ventola e stato di funzionamento (acceso in freddo/caldo o fermo) direttamente sul termostato BTicino.

## Cosa vedrai in Home Assistant

- **Sempre**: un dispositivo **"Bridge"** con lo stato Online/Offline e un pulsante **"Scan Network"** che forza una lettura immediata di tutte le macchine.
- **Modalità `standard`**: tutti i **condizionatori** (caldo/freddo/auto/ventola/deumidifica, 16–30°C) e tutti gli **idronici**.
- **Modalità `integrated`**: solo gli **idronici** e il Bridge. I condizionatori sono gestiti dai termostati BTicino.

## Diagnostica

- Imposta `"log_level": "debug"` per vedere il dettaglio: connessione al controller, letture e pubblicazioni MQTT.
- All'avvio il programma esegue una pulizia dei dispositivi "fantasma" rimasti su MQTT da configurazioni precedenti, così l'elenco in Home Assistant resta sempre allineato al file di configurazione.

---
---

# 🇬🇧 English

## User Guide

This program is the "brain" that connects your **Mitsubishi** air‑conditioning system (via the **AE‑200 / EW‑50 / AG‑150A** controllers) to **Home Assistant**, using **MQTT**.

It reads the real‑time state of every unit (air conditioners/fan coils and hydronic systems such as heat pumps, domestic‑hot‑water boilers and radiant floors) and publishes it to MQTT, from which Home Assistant automatically creates the climate entities (auto‑discovery). In the same way it forwards to the units the commands you issue from Home Assistant.

## The two operating modes

The program can work in two ways, selected with the `operating_mode` parameter:

- **`standard`** — In Home Assistant you see **all** devices (air conditioners and hydronics) with all their properties: temperature, mode (heat/cool/auto/dry/fan), fan speed.
- **`integrated`** — Designed for those who also use **BTicino thermostats**. The **air conditioners are hidden** in Home Assistant, because the BTicino thermostats control them. The bridge:
  - **listens** to the BTicino thermostats (via MQTT) and turns the fan coils on/off accordingly;
  - **re‑publishes** the real state of each fan coil to MQTT, indexed by **BTicino zone**, so the BTicino bridge can show it on its thermostats;
  - the **hydronics remain visible** in this mode too.

### The "boost" in integrated mode
In `integrated` you can set a margin that delays turning the fan coils on:
- **`heating_boost_delta`** (heating): the fan coil starts **only** when the room is this many degrees **below** the setpoint. Example with `3.0`: if the setpoint is 21°C, the fan coil kicks in only below 18°C, **to assist** the radiant floor system (which on its own would take longer).
- **`cooling_boost_delta`** (cooling): the fan coil starts when the room exceeds the setpoint by this many degrees. With `0.0` it starts as soon as the temperature goes above the setpoint.

To avoid constant on/off cycling around the setpoint, the program applies a small **hysteresis** (≈0.3°C): the unit switches off only after crossing the setpoint by that margin.

## Requirements

- A Mitsubishi **AE‑200 / EW‑50 / AG‑150A** controller reachable on the network (with the interface that communicates over WebSocket).
- An **MQTT broker** (e.g. Mosquitto).
- **Home Assistant** with the **MQTT** integration enabled (auto‑discovery is built in).

## Installation

The program looks for its configuration in two places, in order:
1. `/data/options.json` → if present (typical when running as a **Home Assistant Add‑on**).
2. `appsettings.json` → in the program folder (**standalone** use, e.g. on Windows/Linux).

## Configuration

The configuration is split into blocks. Complete, working example:

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
    "username": "system",
    "password": "your-password",
    "base_topic": "mitsubishi_bridge",
    "discovery_prefix": "homeassistant"
  },
  "advanced": {
    "log_level": "info"
  },
  "air_conditioners": {
    "devices": [
      { "id": "16", "name": "1 sala sud VRF", "bticino_zone": "61", "supports_dry": false }
    ]
  },
  "hydronics": {
    "devices": [
      { "id": "01", "name": "Domestic hot water", "type": "HOT_WATER" },
      { "id": "02", "name": "Radiant heating", "type": "HEATING" }
    ]
  }
}
```

### `mitsubishi` block
| Parameter | Meaning |
|---|---|
| `host` | IP address of the AE‑200/EW‑50/AG‑150A controller. |
| `polling_interval` | How often (in **seconds**) to re‑read the state (minimum 5). |
| `operating_mode` | `standard` (everything visible) or `integrated` (see above). |
| `bticino_base_topic` | `integrated` only: base topic of the BTicino bridge to listen to (usually `bticino_bridge`). |
| `heating_boost_delta` | `integrated` only: °C margin below setpoint to start the fan coil in heating. |
| `cooling_boost_delta` | `integrated` only: °C margin above setpoint to start the fan coil in cooling. |

### `mqtt` block
| Parameter | Meaning |
|---|---|
| `host` / `port` | Address and port of the MQTT broker (typical port `1883`). |
| `username` / `password` | MQTT credentials (leave empty for anonymous access). |
| `base_topic` | Root of this program's topics (default `mitsubishi_bridge`). |
| `discovery_prefix` | Home Assistant auto‑discovery prefix: keep `homeassistant`. |

### `advanced` block
| Parameter | Meaning |
|---|---|
| `log_level` | Log verbosity: `debug`, `info`, `warning`, `error`. |

### `air_conditioners` block (air conditioners / fan coils)
Each device inside `devices`:
| Field | Meaning |
|---|---|
| `id` | The unit's **M‑Net address** on the controller (e.g. `"16"`). |
| `name` | Friendly name shown in Home Assistant. |
| `bticino_zone` | `integrated` only: number of the **BTicino thermostat zone** paired with this unit. It is the "key" that links the two systems. |
| `supports_dry` | `true` if the unit supports dehumidification (adds the "dry" mode). |

### `hydronics` block (heat pumps / boilers / radiant)
| Field | Meaning |
|---|---|
| `id` | The unit's M‑Net address. |
| `name` | Friendly name. |
| `type` | `HOT_WATER` (domestic‑hot‑water boiler, 30–70°C) or `HEATING` (radiant floor, 20–40°C). |

> **How do I find the `id` (M‑Net address)?** It is the number under which the unit is registered in the Mitsubishi controller (the same you see in the AE‑200 web interface). Write it as a string, including a leading zero if needed (e.g. `"03"`).

## Use with BTicino thermostats (integrated mode)

1. Set `"operating_mode": "integrated"`.
2. For each air conditioner, set `bticino_zone` to the **zone number** of the matching BTicino thermostat.
3. **On the BTicino thermostat**: in the parameter where you normally set the **electro‑valve** number, set the value **Gateway**. This tells the thermostat that cooling (and/or heating) must go through the VRF gateway, not through a valve.
4. Make sure the **BTicino bridge is running**: it is the one publishing the thermostats to Home Assistant, while this program provides the real state of the units.

In this mode the air conditioners do **not** appear as separate entities in Home Assistant: their states are published to `mitsubishi_bridge/climate/<zone>/…` and read by the BTicino bridge to show temperature, fan speed and running state (cooling/heating or idle) directly on the BTicino thermostat.

## What you will see in Home Assistant

- **Always**: a **"Bridge"** device with the Online/Offline status and a **"Scan Network"** button that forces an immediate read of all units.
- **`standard` mode**: all **air conditioners** (heat/cool/auto/fan/dry, 16–30°C) and all **hydronics**.
- **`integrated` mode**: only the **hydronics** and the Bridge. The air conditioners are handled by the BTicino thermostats.

## Diagnostics

- Set `"log_level": "debug"` to see the details: controller connection, reads and MQTT publications.
- At startup the program cleans up "ghost" devices left on MQTT from previous configurations, so the list in Home Assistant always matches the configuration file.
