//deploy.js
const hre = require("hardhat");
async function main() {
  // ethers is avaialble in the global scope
  const [deployer] = await hre.ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const JobPlatform = await hre.ethers.getContractFactory("JobPlatform");
  const jobPlatform = await JobPlatform.deploy();
  await jobPlatform.deployed();

  console.log("JobPlatform address:", jobPlatform.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
