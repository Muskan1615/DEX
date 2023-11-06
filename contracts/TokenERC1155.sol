// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract SemiFungible is ERC1155 {
    uint256 public constant GOLD = 0;
    uint256 public constant NFT = 1;

    constructor() ERC1155("SemiFungible") {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        _mint(to, id, amount, data);
    }
}
