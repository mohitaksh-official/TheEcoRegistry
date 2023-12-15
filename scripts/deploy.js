const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const EnvironmentalImpactTCR = await ethers.getContractFactory("TCR");
  const environmentalImpactTCR = await EnvironmentalImpactTCR.deploy();
   // Wait for deployment to be confirmed

  console.log("EnvironmentalImpactTCR deployed to:", environmentalImpactTCR.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
