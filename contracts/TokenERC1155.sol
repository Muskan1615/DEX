// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TokenERC1155 is ERC1155 {
    constructor() ERC1155("TokenERC1155") {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        _mint(to, id, amount, data);
    }

    function mintBatch(
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) public {
        _mintBatch(msg.sender, ids, values, data);
    }
}
