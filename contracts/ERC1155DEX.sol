// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract ERC1155DEX is ERC1155Holder {
    IERC1155 public erc1155Token;
    uint256[] public totalIds;

    mapping(address => uint) public balanceOf;
    mapping(uint => uint) public reserves;
    uint256 totalSupply;

    constructor(address _erc1155Address) {
        erc1155Token = IERC1155(_erc1155Address);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _update(uint256[] memory _tokenIds) private {
        for (uint i = 0; i < _tokenIds.length; i++) {
            reserves[_tokenIds[i]] = erc1155Token.balanceOf(
                address(this),
                _tokenIds[i]
            );
        }
    }

    function _updateNew(
        uint _idONE,
        uint _reserveONE,
        uint _idTWO,
        uint _reserveTWO
    ) private {
        reserves[_idONE] = _reserveONE;
        reserves[_idTWO] = _reserveTWO;
    }

    function checkIds(uint _id) public view returns (bool) {
        for (uint i = 0; i < totalIds.length; i++) {
            if (totalIds[i] == _id) {
                return true;
            }
        }
        return false;
    }

    function swap(uint256 _idIn, uint256 _amountIn, uint256 _idOut) external {
        require(checkIds(_idIn), "Invalid Id In");
        require(checkIds(_idOut), "Invalid Id Out");
        require(_amountIn > 0, "Amount in = 0");

        erc1155Token.safeTransferFrom(
            msg.sender,
            address(this),
            _idIn,
            _amountIn,
            ""
        );

        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        uint256 amountOut = (reserves[_idOut] * amountInWithFee) /
            (reserves[_idIn] + amountInWithFee);

        erc1155Token.safeTransferFrom(
            address(this),
            msg.sender,
            _idOut,
            amountOut,
            ""
        );
        _updateNew(
            _idIn,
            erc1155Token.balanceOf(address(this), _idIn),
            _idOut,
            erc1155Token.balanceOf(address(this), _idOut)
        );
    }

    function addLiquidity(
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) external {
        require(_ids.length == _amounts.length, "Invalid input lengths");
        for (uint i = 0; i < _ids.length; i++) {
            if (!checkIds(_ids[i])) {
                totalIds.push(_ids[i]);
            }
        }

        for (uint i = 0; i < _ids.length; i++) {
            erc1155Token.safeTransferFrom(
                msg.sender,
                address(this),
                _ids[i],
                _amounts[i],
                ""
            );
        }

        uint256 totalAmount = 0;
        for (uint i = 0; i < _ids.length; i++) {
            require(_amounts[i] > 0, "Invalid amounts");
            totalAmount += _amounts[i];
        }

        if (totalSupply > 0) {
            for (uint i = 0; i < _ids.length; i++) {
                require(
                    reserves[_ids[i]] * totalAmount ==
                        reserves[1 - _ids[i]] * _amounts[i],
                    "x / y != dx / dy"
                );
            }
        }

        uint shares = 1;
        if (totalSupply > 0) {
            for (uint i = 0; i < _ids.length; i++) {
                uint sharesToken = (_amounts[i] * totalSupply) /
                    reserves[_ids[i]];
                shares = (shares < sharesToken) ? shares : sharesToken;
            }
        } else {
            for (uint i = 0; i < _ids.length; i++) {
                shares *= _amounts[i];
            }
            shares = _sqrt(shares);
        }

        _update(_ids);
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
