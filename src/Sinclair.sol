// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract Sinclair is ERC20, ERC20Permit {
    constructor(address initialOwner) ERC20("SINCLAIR", "SIN") ERC20Permit("SINCLAIR") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
