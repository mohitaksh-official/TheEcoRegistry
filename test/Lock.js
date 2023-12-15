// EnvironmentalImpactTCR.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EnvironmentalImpactTCR", function () {
  let EnvironmentalImpactTCR;
  let environmentalImpactTCR;
  let owner;
  let addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    // Deploy the contract using default overrides
    EnvironmentalImpactTCR = await ethers.getContractFactory("TCR");
    environmentalImpactTCR = await EnvironmentalImpactTCR.deploy();

    // Wait for deployment to be confirmed
    //await environmentalImpactTCR.deployed();
  });

  it("Should deploy the contract", async function () {
    expect(await environmentalImpactTCR.owner()).to.equal(owner.address);
  });

  it("Should propose a product and finalize its rating", async function () {
    // Propose a product
    await environmentalImpactTCR.connect(addr1).proposeProduct("TestProduct", 50);
    const proposalId = 1;

    // Challenge the product proposal
    await environmentalImpactTCR.connect(addr1).challengeProduct(proposalId);

    // Vote on the product proposal
    await environmentalImpactTCR.connect(owner).voteOnProduct(proposalId, true);

    // Finalize the product's rating (only owner can do this)
    await environmentalImpactTCR.connect(owner).finalizeRating(proposalId);

    // Check if the proposer received the correct amount of tokens based on the final rating
    const proposerBalance = await environmentalImpactTCR.balanceOf(addr1.address);
    expect(proposerBalance).to.equal(50);
  });
});
