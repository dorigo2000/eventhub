# Eventhub
`Eventhub` è un'applicazione web che permette ad utenti ed organizzatori di gestire la creazione di eventi e la prenotazione ad essi.

## Funzionalità
`Eventhub` implementa le seguenti funzionalità:
- Registrazione di utenti ed organizzatori
- Permettere ad organizzatori di creare eventi caratterizzati da:
  - Nome
  - Data e orario di inizio
  - Data e orario di fine
  - Città
  - Indirizzo
  - Massimo numero di partecipanti
- Permettere agli utenti di:
  - Ricercare eventi filtrando per città
  - Registrarsi e deregistrarsi ad eventi
- Impedire ad utenti di registrarsi ad un evento se concomitante ad un altro ai quali sono già iscritti
- Permettere agli organizzatori di consultare la lista dei partecipanti ai propri eventi ed eventualmente rimuovere utenti iscritti indesiderati ad essi

## Notifiche
`Eventhub` implementa un sistema di notifiche che permette ad utenti registrati ad un evento di ricevere aggiornamenti nel caso in cui esso ha avuto variazioni, se esso viene annullato dall'organizzatore, o se essi sono stati rimossi. Allo stesso modo, gli organizzatori ricevono delle notifiche nel caso in cui gli eventi da essi creati abbiano raggiunto la massima capienza.