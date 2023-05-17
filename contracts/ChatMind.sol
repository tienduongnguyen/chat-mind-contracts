// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ChatMind is ERC20 {
    constructor(uint256 initialSupply) ERC20("Chat Mind", "CMD") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}
