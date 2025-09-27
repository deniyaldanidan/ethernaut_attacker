// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";
import {ElevatorAttacker} from "../src/ElevatorAttacker.sol";

contract ElevatorAttackerExecutor is Script, HelperConfigLib {
    function run() external {
        vm.startBroadcast(ATTACKER_KEY);
        ElevatorAttacker attacker = new ElevatorAttacker();

        attacker.attack(0x24B3c7704709ed1491473F30393FFc93cFB0FC34);

        vm.stopBroadcast();
    }
}
