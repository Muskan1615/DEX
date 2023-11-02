// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint public reserveA;
    uint public reserveB;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
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
