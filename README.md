# Reservation

## Introduzione
Questo è uno smart contract per la gestione della prenotazione di un appartamento.
In breve, implementando su blockchain una funzionalità tipica come la cancellazione gratuita di una prenotazione, si eliminerebbe la necessità di riporre la propria fiducia in servizi quali Booking o AirBnb, favorendo un rapporto finanziario diretto tra l'acquirente e il proprietario dell'appartamento. Per il proprietario di un appartamento significherebbe eliminare o quantomeno ridurre le fees da versare ai servizi suddetti, con un chiaro vantaggio economico, mentre l'acquirente potrebbe effettuare prenotazioni con maggiore spensieratezza.

## Lo *smart contract*
Lo *smart contract*, chiamato Reservation, dichiara anzitutto le variabili globali del contratto, cercando di sfruttare al meglio la sintassi di Solidity. Ad esempio, la variabile `owner`, la quale è inizializzata all'interno del metodo costruttore e poi mai più modificata, è dichiarata con la parola chiave `immutable`. Anche la struct apartment è immutabile, nel senso suddetto. Tuttavia Solidity, almeno fino all'attuale versione 0.8.5, non consente di dichiarare struct come immutabili.
La variabile `reserver`, invece, non è immutabile: il reserver può cambiare in seguito a una prenotazione effettuata con successo, oppure in seguito a una cancellazione valida. Di default, l'indirizzo del reserver è `EMPTY_RESERVER`.

Sono dichiarati due *events*. Gli eventi consentono di creare dei log delle attività svolte con lo smart contract: Interfacce come etherscan tengono traccia degli eventi emessi da uno smart contract, così che sia possibile rivedere tutta la storia delle prenotazioni e cancellazioni.

Poi, sono dichiarati dei *modifier*. Un modifier è qui utilizzato per specificare dei requisiti di una funzione. Ad esempio, se una funzione può essere utilizzata soltanto dal proprietario dell'appartamento, nella *signature* di tale funzione sarà presente il modifier `onlyOwner`.

Il metodo costruttore crea un Apartment con i valori passati a esso come argomenti.

Infine, sono implementate le funzioni dello *smart contract*.

## Sicurezza
Basandomi sul [capitolo 9 del libro "Mastering Ethereum"](https://github.com/ethereumbook/ethereumbook/blob/develop/09smart-contracts-security.asciidoc), di Andreas Antonopulous, ho apportato alcune modifiche allo *smart contract*, al fine di eliminare o evitare alcune possibili vulnerabilità.

Per evitare *reentrancy attacks*, ho spostato tutta la logica che modifica le variabili di stato prima della chiamata del metodo `.transfer()`.
Inoltre, ho usato il modifier *nonReentrant* della [libreria ReentrancyGuard](https://docs.openzeppelin.com/contracts/3.x/api/utils#ReentrancyGuard).

Per evitare *unexpected ether attacks*, ho eliminato ogni riferimento a `address(this).balance`, facendo invece riferimento alla variabile `apartment.cost`, il cui valore è definito una volta soltanto nel metodo costruttore.

Non sono presenti problemi di *aritmethic underflows/overflows*; problemi di visibilità di default sono affrontati a livello sintattico dalla versione di Solidity impiegata; le altre possibili vulnerabilità non sono state studiate, per ora.

Lo smart contract è stato analizzato utilizzando il tool [Mythril](https://github.com/ConsenSys/mythril): esso non ha rilevato problemi di sicurezza.

## Interfaccia utente
Ho creato un server Express.js, il quale si limita a renedere disponibile nel browser una pagina HTML tramite la quale è possibile interagire con lo smart contract e con il wallet MetaMask.

Brevemente, funziona così: all'apertura della pagina web, se il wallet MetaMask non è online, si apre una pagina per l'apertura dello stesso.

Nel mentre, lo smart contract è interrogato al fine di controllare lo stato della prenotazione:
- se l'appartamento è libero, appare un banner con sfondo verde: "The apartment is free for booking!" seguito da un pulsante che contente di effettuare una prenotazione.
- se l'appartamento è già stato prenotato, un banner blu ci avvisa di questo, e un pulsante per la cancellazione della prenotazione è reso disponibile.
- altrimenti, un banner rosso ci avvisa della prenotazione dell'appartamento da parte di altri.

La pagina web si ricarica quando MetaMask completa una transazione richiesta attraverso la stessa (ad esempio, dopo aver effettuato una valida prenotazione dell'appartamento).

Le informazioni fondamentali dell'appartamento sono incluse nello smart contract e definite al momento della creazione dello stesso.

Nello smart contract si è dovuto gestire il problema delle date: non esiste un preciso metodo di gestione delle date in Ethereum. L'unica informazione temporale disponibile è il timestamp dell'ultimo blocco minato, accessibile tramite la variabile globale `block.timestamp`.

## Test
Le funzioni implementate nello *smart contract* sono state testate utilizzando la suite di testing in Solidity fornita dall'IDE Remix.

Utilizzare dei file di test si è rivelato particolarmente utile nel caso di uno smart contract, perché consente di evitare la compilazione, pubblicazione, utilizzo dello smart contract, con tutte le lentezze allegate, e, immaginando una publicazione nella main network, il testing consente anche di risparmiare denaro: non è necessario spendere soldi per chiamare le funzioni dello smart contract!

## Possibili miglioramenti
### Potenziare l'applicazione
Attualmente, l'applicazione gestisce un solo *smart contract*, il quale riguarda la prenotazione di un singolo appartamento, in un periodo di tempo fissato.

Sarebbe interessante trasformare l'applicazione in uno *hub*, dove chiunque possa pubblicare un annuncio.
Questo non richiederebbe nessuna registrazione: basterebbe fornire l'indirizzo e il codice ABI dello *smart contract* per renderlo visibile nell'applicazione. Le due suddette informazioni devono essere salvate in un database. Periodicamente, si può interrogare ciascuno *smart contract* e cancellarlo qualora l'annuncio sia scaduto.

Inoltre, sarebbe interessante dare la possibilità di gestire la prenotazione di un appartamento in un intervallo di tempo variabile.
In altri termini, l'app funzionerebbe come un AirBnb o un Booking. Quando però l'utente chiede di effettuare o cancellare una prenotazione, tali richieste
sono 'scolpite' nella blockchain di Ethereum, con tutti i vantaggi che ne derivano.

### Migliorare la sicurezza dello *smart contract*
Nel capitolo 9 del libro Mastering Ehtereum sono elencati numerosi tipi di attacco contro cui lo smart contract non è ancora stato testato.

Sarebbe inoltre interessante seguire i consigli di [OpenZeppelin](https://openzeppelin.com/) sempre al fine di migliorare la sicurezza dello *smart contract* e sfruttare le nascenti *best practices* nella scrittura degli stessi.

Bisognerebbe anche seguire queste [Ethereum smart contract security best practices](https://consensys.github.io/smart-contract-best-practices/).

### Scrivere una documentazione precisa dello *smart contract*

## Assunzioni
- `block.timestamp` corrisponde, con buona approssimazione, al tempo presente.
- Colui che pubblica lo smart contract è il reale proprietario dell'appartamento
- l'appartamento esiste e ha le proprietà scritte in blockchain

## Come usare questo repository
Anzitutto, bisogna pubblicare lo smart contract contenuto nella cartella [contracts](./contracts). Come? Personalmente, ho aperto lo smart contract nell'[IDE Remix](https://remix.ethereum.org/), lo ho compilato e poi pubblicato. La compilazione avviene nella sezione di Remix "Solidity compiler"; la pubblicazione avviene tramite la sezione "Deploy and run transactions". In quest'ultima, è importante selezionare "Injected Web3" come environment, oltre a specificare un valore per ciascun parametro richiesto dal metodo costruttore dello smart contract. "Injected Web3" permette a Remix di dialogare con MetaMask, il wallet Ethereum da me utilizzato nel corso di questo progetto. Esso è un'estensione per browser.

Una volta pubblicato lo smart contract, è bene salvarsi il suo indirizzo e il suo codice ABI. Essi devono essere scritti all'interno del file [./assets/js/connect.js](./assets/js/connect.js).

Bisogna infine avviare il web server che rende disponibile il sito web tramite il quale gestire lo smart contract. Aprire un terminale nella cartella del progetto, installare le dipendenze Node.js con il comando `npm install`, quindi avviare il web server con il comando `node server.js`.

Ora, collegandosi all'indirizzo [http://localhost:3000](http://localhost:3000), dovrebbe essere possibile l'interazione con lo smart contract.