const ABI = [{"inputs":[{"internalType":"uint256","name":"_startTimestamp","type":"uint256"},{"internalType":"uint256","name":"_endTimestamp","type":"uint256"},{"internalType":"uint256","name":"_cost","type":"uint256"},{"internalType":"uint8","name":"_bathrooms","type":"uint8"},{"internalType":"uint8","name":"_beds","type":"uint8"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"by","type":"address"}],"name":"bookCancelled","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"by","type":"address"}],"name":"bookConfirmed","type":"event"},{"inputs":[],"name":"apartment","outputs":[{"internalType":"uint256","name":"startTimestamp","type":"uint256"},{"internalType":"uint256","name":"endTimestamp","type":"uint256"},{"internalType":"uint256","name":"cost","type":"uint256"},{"internalType":"uint8","name":"bathrooms","type":"uint8"},{"internalType":"uint8","name":"beds","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"book","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"cancel","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"destruct","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"isBooked","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"reserver","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"}];
const ADDRESS = '0x9604bce0cef805a2fd3555aa49328cf6299413f7';

await window.ethereum.request({method: 'eth_requestAccounts'});
const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(ABI, ADDRESS);

const apartment = await contract.methods.apartment().call();

let startTimestamp = parseInt(apartment['startTimestamp']) * 1000;
const startDate = new Date(startTimestamp);

let endTimestamp = parseInt(apartment['endTimestamp']) * 1000;
const endDate = new Date(endTimestamp);

const ul = document.getElementsByTagName('ul')[0];
ul.innerHTML = `
<li>Cost: ${web3.utils.fromWei(apartment['cost'], 'ether')} ether<\li>
<li>Start date: ${startDate.toDateString()}<\li>
<li>End date: ${endDate.toDateString()}<\li>
<li>Bathrooms: ${apartment['bathrooms']}<\li>
<li>Beds: ${apartment['beds']}<\li>
`

const MY_ADDRESS = window.ethereum.selectedAddress;
const EMPTY_RESERVER = '0x0000000000000000000000000000000000000000';
const reserver = (await contract.methods.reserver().call());
const banner = document.getElementsByClassName('banner')[0];

if (reserver === EMPTY_RESERVER) {
    banner.innerHTML = `The apartment is free for booking!`;
    banner.style.background = 'rgb(0, 190, 0)'
    banner.parentNode.appendChild(newButton('Book the apartment', book));
} else if (reserver.toUpperCase() === MY_ADDRESS.toUpperCase()) {
    banner.innerHTML = `You've already booked this apartment.`;
    banner.style.background = 'rgb(0, 153, 200)';
    banner.parentNode.appendChild(newButton('Cancel the reservation', cancel));
} else {
    banner.style.background = 'rgb(200, 63, 0)';
    banner.innerHTML = `The apartment is already booked by another person.`;
}

function newButton(_innerHTML, _onClickEvent) {
    let button = document.createElement('button');
    button.type = 'submit';
    button.addEventListener('click', _onClickEvent);
    button.innerHTML = _innerHTML;
    return button;
}

function book() {
    contract.methods.book().send({from: MY_ADDRESS, value: apartment['cost']}).then(refresh);
}

function cancel() {
    contract.methods.cancel().send({from: MY_ADDRESS}).then(refresh);
}

function refresh() {
    location = location; // A way to refresh the webpage.
}
