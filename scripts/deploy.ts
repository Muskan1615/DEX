import { ethers } from "hardhat";

async function main() {
  const wallet = (await ethers.getSigners())[0];
  let balanceBefore = await ethers.provider.getBalance(wallet.address);
  console.log(balanceBefore);

  const TokenA = await ethers.getContractFactory("TokenA");
  const tokenA = await TokenA.deploy();
  tokenA.waitForDeployment;
  console.log("TokenA deployed to:", await tokenA.getAddress());

  const TokenB = await ethers.getContractFactory("TokenB");
  const tokenB = await TokenB.deploy();
  tokenB.waitForDeployment;
  console.log("TokenB deployed to:", await tokenB.getAddress());

  const DEX = await ethers.getContractFactory("SimpleDEX");
  const dex = await DEX.deploy(tokenA.getAddress(), tokenB.getAddress());
  dex.waitForDeployment;
  console.log("DEX deployed to:", await dex.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
