const {expect} = require("chai");
const {ethers} = require("ethers");

describe("Token contract", function() {
    it("Deployment should mint tokens and assign the total token to specified address", async function(){

        const [owner] =await ethers.getSigners();
        const Token = await ethers.getContractFactory("sushiToken");
        const sushiToken = await Token.deploy("SushiToken", "SUSHI");

        await sushiToken.mint(account[0],1000);
        const ownerBalance = await hardhatToken.balanceOf(account[0]);
        expect(await sushiToken.totalSupply()).to.equal(ownerBalance);
    });
});