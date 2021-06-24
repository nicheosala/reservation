// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "remix_tests.sol"; 
import "../contracts/Reservation.sol";

contract tests {

    Reservation reservation;
    uint constant testCost = 100;
    uint constant testStartTimestamp = 1627776000;
    uint constant testEndTimestamp = 1628416800;
    
    // Accept any incoming amount.
    receive () external payable {}
    
    function beforeAll() public {
        reservation = new Reservation(testStartTimestamp, testEndTimestamp, testCost, 2, 8);
    }
    
    function testConstructor() public {
        Assert.equal(reservation.reserver(), payable(address(0)),
        'The reserver should be empty just after contract creation.');
    }
    
    function testBadConstructor() public {
        try new Reservation(testEndTimestamp, testStartTimestamp, testCost, 2, 8) {
            /* Nothing to do here: we expect an error. */
        } catch Error(string memory reason) {
            Assert.equal(reason, 'You cannot propose a reservation with start timestamp smaller than end timestamp.',
            'Creating a reservation with a start timestamp smaller than the end timestamp should not be allowed.');
        }
    }

    function testIsBooked() public {
        Assert.equal(reservation.isBooked(), false,
        'The reservation should not be booked by default.');
    }

    /// #value: 100
    function testBook() public payable {
        try reservation.book{value: 100}() {
            Assert.equal(reservation.isBooked(), true,
            'The reservation should be booked after a valid call to book().');
        } catch Error(string memory reason) {
            Assert.ok(false, reason);
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
    }
    
    /// #value: 100
    function testAlreadyBooked() public payable {
        try reservation.book{value: 100}() {
            /* Nothing to do here: we expect an error. */
        } catch Error(string memory reason) {
            Assert.equal(reason, 'The apartment is already booked.',
            'Booking a reservation that is already booked should not be allowed.');
        }
    }
    
    /// #value: 200
    function testInvalidBookValue() public payable {
        try reservation.book{value: 200}() {
            /* Nothing to do here: we expect an error. */
        } catch Error(string memory reason) {
            Assert.equal(reason, 'The reserver should pay exactly the cost of the apartment.',
            'Booking an apartment not paying the exact cost should not be allowed.');
        }
    }
    
    function testCancel() public {
        uint old_balance = address(this).balance;
        try reservation.cancel() {
            Assert.equal(reservation.isBooked(), false,
            'The reservation should not be booked after a valid call to cancel().');
            Assert.equal(address(this).balance - old_balance, 100,
            'Cancelling the reservation, the reserver should get back exactly the cost of the apartment.');
        } catch Error(string memory reason) {
            Assert.ok(false, reason);
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
    }
    
    function testInvalidCancel() public {
        try reservation.cancel() {
            /* Nothing to do here: we expect an error. */
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Only the actual reserver can perform this operation.',
            'Cancelling a reservation that is not booked should not be allowed.');
        }
    }
}
