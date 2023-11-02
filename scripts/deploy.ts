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

  // Get the balance of TokenA in your wallet
  const balanceA = await tokenA.balanceOf(wallet.address);

  // Get the balance of TokenB in your wallet
  const balanceB = await tokenB.balanceOf(wallet.address);

  console.log(`TokenA Balance: ${balanceA.toString()}`);
  console.log(`TokenB Balance: ${balanceB.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
