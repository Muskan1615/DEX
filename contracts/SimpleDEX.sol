// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract SimpleDEX {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    IERC1155 public immutable semiFungible;
    uint256 public constant GOLD = 0;
    uint256 public constant NFT = 1;

    uint public reserveA;
    uint public reserveB;
    uint256 public reserveGOLD;
    uint256 public reserveNFT;

    uint public totalSupply;
    mapping(uint256 => uint256) private supplies;

    mapping(address => uint) public balanceOf;
    mapping(address => uint256) public semiFungibleBalanceOf;

    constructor(address _tokenA, address _tokenB, address _semiFungible) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        semiFungible = IERC1155(_semiFungible);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    //   Mint new tokens
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        // mint(account, id, amount, data);
        balanceOf[account] += amount;

        supplies[id] += amount;
    }

    // Burn tokens
    function burn(address account, uint256 id, uint256 amount) public {
        // burn(account, id, amount);
        balanceOf[account] -= amount;

        supplies[id] -= amount;
    }

    function _update(uint _reserveA, uint _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    function swap(
        address _tokenIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        require(
            _tokenIn == address(tokenA) || _tokenIn == address(tokenB),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");

        bool istokenA = _tokenIn == address(tokenA);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint reserveIn,
            uint reserveOut
        ) = istokenA
                ? (tokenA, tokenB, reserveA, reserveB)
                : (tokenB, tokenA, reserveB, reserveA);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);

        tokenOut.transfer(msg.sender, amountOut);

        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
    }

    function addLiquidity(
        uint _amountA,
        uint _amountB
    ) external returns (uint shares) {
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transferFrom(msg.sender, address(this), _amountB);
        if (reserveA > 0 || reserveB > 0) {
            require(
                reserveA * _amountB == reserveB * _amountA,
                "x / y != dx / dy"
            );
        }
        if (totalSupply == 0) {
            shares = _sqrt(_amountA * _amountB);
        } else {
            shares = _min(
                (_amountA * totalSupply) / reserveA,
                (_amountB * totalSupply) / reserveB
            );
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
    }

    function swapERC1155(
        uint _tokenIdIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        require(_tokenIdIn == GOLD || _tokenIdIn == NFT, "Invalid token ID");
        require(_amountIn > 0, "amount in = 0");
        uint256 tokenIdOut = _tokenIdIn == GOLD ? GOLD : NFT;

        uint256 reserveIn = _tokenIdIn == GOLD ? reserveGOLD : reserveNFT;
        uint256 reserveOut = _tokenIdIn == GOLD ? reserveNFT : reserveGOLD;

        amountOut = (reserveOut * _amountIn) / reserveIn;

        require(amountOut > 0, "Insufficient liquidity");

        burn(msg.sender, _tokenIdIn, _amountIn);
        mint(msg.sender, tokenIdOut, amountOut, "");

        if (_tokenIdIn == GOLD) {
            reserveGOLD -= _amountIn;
            reserveNFT += amountOut;
        } else {
            reserveGOLD += amountOut;
            reserveNFT -= _amountIn;
        }
    }

    function addLiquidityERC1155(uint _amountGOLD, uint _amountNFT) external {
        require(
            _amountGOLD > 0 || _amountNFT > 0,
            "amounts must be greater than 0"
        );

        mint(msg.sender, GOLD, _amountGOLD, "");
        mint(msg.sender, NFT, _amountNFT, "");

        reserveGOLD += _amountGOLD;
        reserveNFT += _amountNFT;
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