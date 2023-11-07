// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract ERC1155DEX is ERC1155Holder {
    IERC1155 public erc1155Token;
    uint256 public constant GOLD = 1;
    uint256 public constant NFT = 2;
    uint256 public reserveGOLD;
    uint256 public reserveNFT;
    uint256 public totalSupply;

    mapping(address => uint) public balanceOf;

    constructor(address _erc1155Address) {
        erc1155Token = IERC1155(_erc1155Address);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserveGOLD, uint _reserveNFT) private {
        reserveGOLD = _reserveGOLD;
        reserveNFT = _reserveNFT;
    }

    function swap(uint256 _idIn, uint256 _amountIn) external {
        require(_idIn == GOLD || _idIn == NFT, "Invalid token");
        require(_amountIn > 0, "Amount in = 0");

        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);

        ids[0] = _idIn;
        amounts[0] = _amountIn;

        erc1155Token.safeBatchTransferFrom(
            msg.sender,
            address(this),
            ids,
            amounts,
            ""
        );

        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        if (_idIn == GOLD) {
            uint256 amountOut = (reserveNFT * amountInWithFee) /
                (reserveGOLD + amountInWithFee);
            erc1155Token.safeTransferFrom(
                address(this),
                msg.sender,
                NFT,
                amountOut,
                ""
            );
            _update(
                erc1155Token.balanceOf(address(this), GOLD),
                erc1155Token.balanceOf(address(this), NFT)
            );
        } else {
            uint256 amountOut = (reserveGOLD * amountInWithFee) /
                (reserveNFT + amountInWithFee);
            erc1155Token.safeTransferFrom(
                address(this),
                msg.sender,
                GOLD,
                amountOut,
                ""
            );
            _update(
                erc1155Token.balanceOf(address(this), NFT),
                erc1155Token.balanceOf(address(this), GOLD)
            );
        }
    }

    function addLiquidity(
        uint256 _idGOLD,
        uint256 _idNFT,
        uint256 _amountGOLD,
        uint256 _amountNFT
    ) external {
        require(_amountGOLD > 0 && _amountNFT > 0, "Invalid amounts");

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);

        ids[0] = _idGOLD;
        amounts[0] = _amountGOLD;
        ids[1] = _idNFT;
        amounts[1] = _amountNFT;

        erc1155Token.safeBatchTransferFrom(
            msg.sender,
            address(this),
            ids,
            amounts,
            ""
        );

        if (reserveGOLD > 0 || reserveNFT > 0) {
            require(
                reserveGOLD * _amountNFT == reserveNFT * _amountGOLD,
                "x / y != dx / dy"
            );
        }

        if (totalSupply == 0) {
            uint shares = _sqrt(_amountGOLD * _amountNFT);
            _mint(msg.sender, shares);
        } else {
            uint sharesGOLD = (_amountGOLD * totalSupply) / reserveGOLD;
            uint sharesNFT = (_amountNFT * totalSupply) / reserveNFT;
            uint shares = _min(sharesGOLD, sharesNFT);
            require(shares > 0, "Shares = 0");
            _mint(msg.sender, shares);
        }

        _update(
            erc1155Token.balanceOf(address(this), _idGOLD),
            erc1155Token.balanceOf(address(this), _idNFT)
        );
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}
