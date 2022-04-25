const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Gobeam Token", function () {
  let Token;
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("GobeamToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    hardhatToken = await Token.deploy();
  });

  it("Deployment should assign the total supply of tokens to the owner", async () => {
    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Check if token name is GobeamToken", async () => {
    expect(await hardhatToken.name()).to.equal("GobeamToken");
  });

  it("Check if symbol is GOBEAM", async () => {
    expect(await hardhatToken.symbol()).to.equal("GOBEAM");
  });

  it("Check decimals is 18", async () => {
    expect(await hardhatToken.decimals()).to.equal(18);
  });

  it("Check if total supply is 1000000000 * 10 ^ 18", async () => {
    const amount = "1000000000000000000000000000";
    expect(await hardhatToken.totalSupply()).to.equal(
      ethers.BigNumber.from(amount)
    );
  });

  it("Check if treasurer is set to token owner", async () => {
    expect(await hardhatToken.treasurer()).to.equal(owner.address);
  });

  it("Check if address except current treasurer can update treasurer", async () => {
    await expect(
      hardhatToken.connect(addr1).transferTreasurerOwnership(addr2.address)
    ).to.be.revertedWith("Access denied: You should be Treasurer!");
  });

  it("Check if valid treasurer address can update treasurer", async () => {
    await hardhatToken.transferTreasurerOwnership(addr1.address);
    await hardhatToken.connect(addr1).acceptTreasurerOwnership();
    expect(await hardhatToken.treasurer()).to.equal(addr1.address);
  });

  it("Check if user thats doesnot have balance cannot do transfer", async () => {
    await expect(
      hardhatToken.connect(addr1).transfer(addr2.address, 1)
    ).to.be.revertedWith("Token not enough");
  });

  it("Check if error is thrown if token sent to null address", async () => {
    const nullAddress = "0x0000000000000000000000000000000000000000";
    await expect(
      hardhatToken.connect(addr1).transfer(nullAddress, 1)
    ).to.be.revertedWith("cannot transfer to the zero address");
  });

  it("Check if wallet that have enough balance doesnot throw error", async () => {
    await expect(hardhatToken.transfer(addr2.address, 1000)).to.not.reverted;
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(
      ethers.BigNumber.from("1000000000000000000000")
    );
  });

  it("Check if error is thrown if negative value to transfer is given", async () => {
    await expect(hardhatToken.transfer(addr2.address, -1)).to.be.reverted;
  });

  it("Check if treasurer account is not charged fee if transfer is done from that wallet", async () => {
    const amount = 100 * 10 ** 18;
    await hardhatToken.transfer(addr2.address, 100);
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(
      ethers.BigNumber.from(amount.toString())
    );
  });

  it("Check if treasurer account is not charged fee if transfer is done from that wallet", async () => {
    const amount = 100;
    const fee = (2.5 / 100) * 100;
    // transfer 100 tokens to addr2 from owner
    await hardhatToken.transfer(addr2.address, 100);

    // transfer 100 tokens to addr2 from addr1
    await hardhatToken.connect(addr2).transfer(addr1.address, amount);

    // amount that should be in addr1 after deduction 2.5% fee
    const checkAmount = (amount - fee) * 10 ** 18;

    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(
      ethers.BigNumber.from(checkAmount.toString())
    );
  });
});
