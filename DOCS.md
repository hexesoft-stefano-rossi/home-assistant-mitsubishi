Il software può lavorare in due modi diversi, a seconda di come preferisci 
gestire il comfort della tua casa:

## 1. Scegli la tua Modalità di Lavoro

### A. Modalità DIRETTA (Standard)
In questa modalità, ogni condizionatore Mitsubishi apparirà in Home Assistant 
come un dispositivo separato e indipendente.
* **Cosa vedi:** Avrai una scheda "Clima" dedicata per ogni split o macchina idronica.
* **Cosa puoi fare:** Puoi accendere, spegnere, cambiare modalità e regolare 
la temperatura direttamente dall'app di Home Assistant, esattamente come se usassi 
il telecomando originale.

### B. Modalità INTEGRATA (Automazione Totale)
In questa modalità, i condizionatori Mitsubishi "spariscono" dalla vista di 
Home Assistant. Il controllo passa interamente ai tuoi **termostati Bticino**.
Dovrai utilizzare il programma Hexesoft-Bticino
* **Cosa vedi:** Continuerai a vedere e usare solo i termostati Bticino che 
hai già sulle pareti o nell'app.
* **Cosa succede:** Il programma osserva costantemente le richieste del termostato 
Bticino. Se il termostato rileva che la stanza è troppo fredda o troppo calda rispetto 
al **Delta** impostato, il programma accende automaticamente 
il condizionatore Mitsubishi per supportare l'impianto e raggiungere prima la 
temperatura desiderata.
* **Parametro Fondamentale:** Per ogni macchina dovrai indicare il numero della 
zona Bticino (`bticino_zone`) a cui è fisicamente abbinata.

## 2. L'Effetto "Boost" (Parametri Delta)

Nella Modalità Integrata, puoi decidere quanto deve essere "aggressivo" l'intervento 
del condizionatore tramite i parametri **Delta**. Questi dicono al programma quando 
è il momento di far partire il Mitsubishi in aiuto al Bticino:

* **`heating_boost_delta` (Inverno):** Definisce il distacco termico per il riscaldamento.
    * *Esempio:* Se impostato a **3.0**, il condizionatore partirà solo se la 
    temperatura in stanza è più bassa di 3 gradi rispetto a quella richiesta sul termostato.
* **`cooling_boost_delta` (Estate):** Definisce il distacco termico per il raffreddamento.
    * *Esempio:* Se impostato a **0.0**, il condizionatore partirà immediatamente non 
    appena il termostato Bticino rileva che la temperatura è superiore a quella desiderata.

## 3. Come Configurare i Dispositivi

Per ogni macchina Mitsubishi (Split o Idronico), dovrai compilare i seguenti campi 
della configurazione:

**ID**  Il numero identificativo della macchina sul controller Mitsubishi (es: `01`, `03`).
**Name**  Il nome che vuoi dare alla macchina (es: `Camera Letto`, `Salone`). 
**Bticino Zone**  (**Solo modalità Integrata**) Il numero della zona del termostato 
  Bticino che comanda questa stanza. 
**Supports Dry**  Scrivi `true` se la macchina può deumidificare, altrimenti scrivi `false`. 

The software can work in two different ways, depending on how you prefer 
to manage the comfort of your home:

## 1. Choose your Operating Mode

### A. DIRECT Mode (Standard)
In this mode, each Mitsubishi air conditioner will appear in Home Assistant 
as a separate and independent device.
* **What you see:** You will have a dedicated "Climate" card for each split or hydronic machine.
* **What you can do:** You can turn on, turn off, change the mode, and adjust 
the temperature directly from the Home Assistant app, exactly as if you were using 
the original remote control.

### B. INTEGRATED Mode (Total Automation)
In this mode, the Mitsubishi air conditioners "disappear" from view in 
Home Assistant. Control is entirely handed over to your **Bticino thermostats**.
You will need to use the Hexesoft-Bticino program.
* **What you see:** You will continue to see and use only the Bticino thermostats that 
you already have on the walls or in the app.
* **What happens:** The program constantly monitors the requests from the Bticino 
thermostat. If the thermostat detects that the room is too cold or too hot compared 
to the set **Delta**, the program automatically turns on 
the Mitsubishi air conditioner to support the system and reach the desired 
temperature faster.
* **Key Parameter:** For each machine, you will need to indicate the number of the 
Bticino zone (`bticino_zone`) to which it is physically linked.

## 2. The "Boost" Effect (Delta Parameters)

In Integrated Mode, you can decide how "aggressive" the air conditioner's intervention 
should be through the **Delta** parameters. These tell the program when 
it is time to start the Mitsubishi to help the Bticino system:

* **`heating_boost_delta` (Winter):** Defines the temperature difference for heating.
    * *Example:* If set to **3.0**, the air conditioner will start only if the 
    room temperature is 3 degrees lower than the one requested on the thermostat.
* **`cooling_boost_delta` (Summer):** Defines the temperature difference for cooling.
    * *Example:* If set to **0.0**, the air conditioner will start immediately as 
    soon as the Bticino thermostat detects that the temperature is higher than the desired one.

## 3. How to Configure the Devices

For each Mitsubishi machine (Split or Hydronic), you will need to fill in the following 
configuration fields:

**ID** The identification number of the machine on the Mitsubishi controller (e.g., `01`, `03`).
**Name** The name you want to give the machine (e.g., `Bedroom`, `Living Room`). 
**Bticino Zone** (**Integrated mode only**) The zone number of the Bticino thermostat 
  that controls this room. 
**Supports Dry** Write `true` if the machine can dehumidify, otherwise write `false`.