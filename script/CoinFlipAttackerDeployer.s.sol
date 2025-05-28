// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlipAttacker} from "../src/CoinFlipAttacker.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract CoinFlipAttackerDeployer is Script {
    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(attackerKey);
        new CoinFlipAttacker(0x8e80FFe6Dc044F4A766Afd6e5a8732Fe0977A493); // took it from contract.address
        vm.stopBroadcast();
    }
}

// forge script ./script/CoinFlipAttackerDeployer.s.sol:CoinFlipAttackerDeployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// 0x202CCe504e04bEd6fC0521238dDf04Bc9E8E15aB -> CoinFlipAttacker address

// cast send 0x202CCe504e04bEd6fC0521238dDf04Bc9E8E15aB "flipGuesser()" --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
