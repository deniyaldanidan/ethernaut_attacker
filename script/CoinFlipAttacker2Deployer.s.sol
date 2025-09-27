// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlipAttacker2} from "../src/CoinFlipAttacker2.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract CoinFlipAttacker2Deployer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        new CoinFlipAttacker2(0x94099942864EA81cCF197E9D71ac53310b1468D8); // took it from contract.address
        vm.stopBroadcast();
    }
}

contract CoinFlipAttacker2Executer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        CoinFlipAttacker2 attacker = CoinFlipAttacker2(
            0x59F2f1fCfE2474fD5F0b9BA1E73ca90b143Eb8d0
        );
        attacker.flipGuesser();
        vm.stopBroadcast();
    }
}

// forge script ./script/CoinFlipAttacker2Deployer.s.sol:CoinFlipAttacker2Deployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// 0x71C95911E9a5D330f4D621842EC243EE1343292e -> CoinFlipAttacker2 address

// forge script ./script/CoinFlipAttacker2Deployer.s.sol:CoinFlipAttacker2Executer --rpc-url http://127.0.0.1:8545 --broadcast -vvv
