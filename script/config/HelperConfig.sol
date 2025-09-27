// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script} from "../../lib/forge-std/src/Script.sol";

contract HelperConfigLib is Script {
    uint256 public constant ATTACKER_KEY =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d; // anvil key
    address public constant ATTACKER_ADDRESS =
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // anvil address
}
