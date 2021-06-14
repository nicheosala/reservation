// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.5;

import "remix_tests.sol"; 
import "../contracts/Reservation.sol";

contract tests {

    Reservation reservation;
    uint constant testCost = 100;
    uint constant testStartDate = 1627776000;
    address testOwner;
    
    // Accept any incoming amount.
    receive () external payable {}
    
    function beforeAll() public {
        reservation = new Reservation(testStartDate, testCost);
    }
    
    function testConstructor() public {
        Assert.equal(reservation.reserver(), payable(address(0)),
        'The reserver should be empty.');
    }

    function testIsBooked() public {
        Assert.equal(reservation.isBooked(), false,
        'The reservation should not be booked by default.');
    }

    /// #value: 100
    function testBook() public payable {
        reservation.book{value: 100}();
        Assert.equal(reservation.isBooked(), true,
        'The reservation should be booked after a valid call to book().');
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
        try reservation.cancel() {
            Assert.equal(reservation.isBooked(), false,
            'The reservation should not be booked after a valid call to cancel().');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'The reserver should pay exactly the cost of the apartment.',
            'Booking an apartment not paying the exact cost should not be allowed.');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
    }
    
    function testInvalidCancel() public {
        try reservation.cancel() {
            /* Nothing to do here: we expect an error. */
        } catch Error(string memory reason) {
            Assert.equal(reason, 'The apartment is not booked by you.',
            'Cancelling a reservation that is not booked should not be allowed.');
        }
    }
}
