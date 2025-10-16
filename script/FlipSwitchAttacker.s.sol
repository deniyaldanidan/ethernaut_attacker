// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract FlipSwitchAttacker is Script, HelperConfigLib {
    function run() external {
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
