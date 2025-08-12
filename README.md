# Drosera Trap Contracts

This repository contains the contracts needed to create Traps for the Drosera network, which is designed to capture and process events from other smart contracts on the EVM compatible blockchains.


## Example Usage
To create a trap, you need to implement the `Trap` abstract contract in your contract. The `Trap` contract defines the methods that a trap must implement, such as `collect`, and `shouldRespond`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Trap} from "@drosera/contracts/src/Trap.sol";

contract MyTrap is Trap {
    function collect() external view override returns (bytes memory) {
        address user = 0x1234567890123456789012345678901234567890; // Example user address
        uint256 balance = balanceOf(user);

        return (abi.encode(balance));
    }

    function shouldRespond(
        bytes[] calldata collectOutputs
    ) external pure override returns (bool, bytes memory) {
        uint256 balance = abi.decode(collectOutputs[0], (uint256));
        if (balance < 1000) {
            // If the balance is less than 1000, we want to respond on-chain by adding more tokens to the user or some other action
            return (true, "Balance is less than 1000");
        }
        return (false, "");
    }
}
```

More complex and real use-case examples can be found at https://github.com/drosera-network/examples
