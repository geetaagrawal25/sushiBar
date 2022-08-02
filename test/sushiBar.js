const {expect} = require("chai");
const {ethers} = require("ethers");

describe("Staking Contract", function () {
    it("Deployment should transfer staked token to contract when call enter()", async function () {
        const [owner] = await ethers.getSigners();

        const staking = await ethers.getContractFactory("sushiBar");

        const sushiBar = await staking.deploy(sushiToken);
        await sushiBar.enter(100);
        expect(sushiToken.balanceOf(sushiBar.address)).to.equal(100);
    });
}) ;

describe("Staking Contract", function () {
    it("leave() should transfer staked token back to user with interest if called after preferred time", async function () {
        const [owner] = await ethers.getSigners();

        const staking = await ethers.getContractFactory("sushiBar");

        const sushiBar = await staking.deploy(sushiToken);
        await sushiBar.leave(100);
        expect(sushiToken.balanceOf(owner.address)).greaterThan(100);
    })
}) 