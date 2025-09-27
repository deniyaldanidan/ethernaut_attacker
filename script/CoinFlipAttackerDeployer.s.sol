// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlipAttacker} from "../src/CoinFlipAttacker.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract CoinFlipAttackerDeployer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        new CoinFlipAttacker(0x94099942864EA81cCF197E9D71ac53310b1468D8); // took it from contract.address
        vm.stopBroadcast();
    }
}

// forge script ./script/CoinFlipAttackerDeployer.s.sol:CoinFlipAttackerDeployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// 0x73eccD6288e117cAcA738BDAD4FEC51312166C1A -> CoinFlipAttacker address

// cast send 0x73eccD6288e117cAcA738BDAD4FEC51312166C1A "flipGuesser()" --rpc-url http://127.0.0.1:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
