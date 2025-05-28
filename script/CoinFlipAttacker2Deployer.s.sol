// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlipAttacker2} from "../src/CoinFlipAttacker2.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract CoinFlipAttacker2Deployer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        new CoinFlipAttacker2(0x06cd7788D77332cF1156f1E327eBC090B5FF16a3); // took it from contract.address
        vm.stopBroadcast();
    }
}

contract CoinFlipAttacker2Executer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        CoinFlipAttacker2 attacker = CoinFlipAttacker2(
            0x4C2F7092C2aE51D986bEFEe378e50BD4dB99C901
        );
        attacker.flipGuesser();
        vm.stopBroadcast();
    }
}

// forge script ./script/CoinFlipAttacker2Deployer.s.sol:CoinFlipAttacker2Deployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// 0x4C2F7092C2aE51D986bEFEe378e50BD4dB99C901 -> CoinFlipAttacker2 address

// forge script ./script/CoinFlipAttacker2Deployer.s.sol:CoinFlipAttacker2Executer --rpc-url http://127.0.0.1:8545 --broadcast -vvv
