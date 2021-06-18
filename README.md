# Reservation
## Introduzione
This is a smart contract for managing the booking of an apartment.
In short, by implementing a typical functionality on the blockchain such as free cancellation of a reservation, the need to place one's trust in services such as Booking or AirBnb would be eliminated, favoring a direct financial relationship between the buyer and the owner of the apartment.
For the owner of an apartment it would mean eliminating or at least reducing the fees to be paid for the aforementioned services, with a clear economic advantage, while the buyer could make reservations with greater carefree.

## Lo *smart contract*
Lo *smart contract*, chiamato Reservation, dichiara anzitutto le variabili globali del contratto, cercando di sfruttare al meglio la sintassi di Solidity. Ad esempio, la variabile `owner`, la quale è inizializzata all'interno del metodo costruttore e poi mai più modificata, è dichiarata con la parola chiave `immutable`. Anche la struct apartment è immutabile, nel senso suddetto. Tuttavia Solidity, almeno fino all'attuale versione 0.8.5, non consente di dichiarare struct come immutabili.
La variabile `reserver`, invece, non è immutabile: il reserver può cambiare in seguito a una prenotazione effettuata con successo, oppure in seguito a una cancellazione valida. Di default, l'indirizzo del reserver è 0.

Sono dichiarati due *events*. Gli eventi consentono di creare dei log delle attività svolte con lo smart contract: Interfacce come etherscan tengono traccia degli eventi emessi da uno smart contract, così che sia possibile rivedere tutta la storia delle prenotazioni e cancellazioni. Se si ritiene la funzione non necessaria, è sufficiente eliminare gli eventi dallo smart contract.

Poi, sono dichiarati dei *modifier*. Un modifier è qui utilizzato per specificare dei requisiti di una funzuone. Ad esempio, se una funzione può essere utilizzata soltanto dal proprietario dell'appartamento, nella *signature* di tale funzione sarà presente il modifier *onlyOwner*.

Il metodo costruttore crea un Apartment con i valori passati a esso come argomenti.

Infine, sono implementate le funzioni dello *smart contract*.

## Sicurezza
Basandomi sul [capitolo 9 del libro "Mastering Ethereum"](https://github.com/ethereumbook/ethereumbook/blob/develop/09smart-contracts-security.asciidoc), di Andreas Antonopulous, ho apportato alcune modifiche allo *smart contract*, al fine di eliminare o evitare alcune possibili vulnerabilità.

Per evitare *reentrancy attacks*, ho spostato tutta la logica che modifica le variabili di stato prima della chiamata del metodo *.transfer*.
Inoltre, ho usato il modifier *nonReentrant* della [libreria ReentrancyGuard](https://docs.openzeppelin.com/contracts/3.x/api/utils#ReentrancyGuard).

Per evitare *unexpected ether attacks*, ho eliminato ogni riferimento a `address(this).balance`, facendo invece riferimento alla variabile `apartment.cost`, il cui valore è definito una volta soltanto nel metodo costruttore.

Non sono presenti problemi di *aritmethic underflows/overflows*; problemi di visibilità di default sono affrontati a livello sintattico dalla versione di Solidity impiegata; le altre possibili vulnerabilità non sono state studiate, per ora.

Lo smart contract è stato analizzato utilizzando il tool [Mythril](https://github.com/ConsenSys/mythril): esso non ha rilevato problemi di sicurezza.

## Interfaccia utente
Ho creato un server Express.js, il quale si limita a renedere disponibile nel browser una pagina HTML tramite cui è possibile interagire con lo smart contract e con il wallet MetaMask.

Brevemente, funziona così: all'apertura della pagina web, se il wallet MetaMask non è online, si apre una apgina per l'apertura dello stesso.

Nel mentre, lo smart contract è interrogato al fine di controllare lo stato della prenotazione:
- se l'appartamento è libero, appare un banner con sfondo verde: "The apartment is free for booking!" seguito da un pulsante che contente di effettuare una prenotazione.
- se l'appartamento è già stato prenotato, un banner blu ci avvisa di questo, e un pulsante per la cancellazione della prenotazioneè reso disponibile.
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