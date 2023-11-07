import { ethers } from "hardhat";

async function main() {
  const wallet = (await ethers.getSigners())[0];

  const TokenA = await ethers.getContractFactory("TokenA");
  const tokenA = await TokenA.deploy();
  tokenA.waitForDeployment;
  const tokenAAddr = await tokenA.getAddress();
  console.log("TokenA deployed to:", tokenAAddr);

  const TokenB = await ethers.getContractFactory("TokenB");
  const tokenB = await TokenB.deploy();
  tokenB.waitForDeployment;
  const tokenBAddr = await tokenB.getAddress();
  console.log("TokenB deployed to:", tokenBAddr);

  const TokenERC1155 = await ethers.getContractFactory("TokenERC1155");
  const tokenERC1155 = await TokenERC1155.deploy();
  tokenERC1155.waitForDeployment;
  const tokenERC1155Addr = await tokenERC1155.getAddress();
  console.log("TokenERC1155 deployed to:", tokenERC1155Addr);

  const ERC1155DEX = await ethers.getContractFactory("ERC1155DEX");
  const erc1155DEX = await ERC1155DEX.deploy(tokenERC1155Addr);
  erc1155DEX.waitForDeployment;
  const erc1155DEXAddr = await erc1155DEX.getAddress();
  console.log("ERC1155DEX deployed to:", erc1155DEXAddr);

  const ERC20DEX = await ethers.getContractFactory("ERC20DEX");
  const erc20DEX = await ERC20DEX.deploy(tokenAAddr, tokenBAddr);
  erc20DEX.waitForDeployment;
  const erc20DEXAddr = await erc20DEX.getAddress();
  console.log("ERC20DEX deployed to:", erc20DEXAddr);

  // let balanceA = await tokenA.balanceOf(wallet.address);
  // let balanceB = await tokenB.balanceOf(wallet.address);
  // // let balanceGold = await semiFungible.balanceOf(wallet.address, 0);
  // // let balanceNFT = await semiFungible.balanceOf(wallet.address, 1);

  // console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  // console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);
  // // console.log(`Gold Balance: ${Number(balanceGold)}`);
  // // console.log(`NFT Balance: ${Number(balanceNFT)}`);

  // await tokenA.mint(wallet.address, ethers.parseEther("200"));
  // await tokenB.mint(wallet.address, ethers.parseEther("200"));
  // // await semiFungible.mint(wallet.address, 0, 200, "0x00");
  // // await semiFungible.mint(wallet.address, 1, 1, "0x00");

  // balanceA = await tokenA.balanceOf(wallet.address);
  // balanceB = await tokenB.balanceOf(wallet.address);
  // // balanceGold = await semiFungible.balanceOf(wallet.address, 0);
  // // balanceNFT = await semiFungible.balanceOf(wallet.address, 1);

  // console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  // console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);
  // // console.log(`Gold Balance: ${Number(balanceGold)}`);
  // // console.log(`NFT Balance: ${Number(balanceNFT)}`);

  // await tokenA.approve(dexAddr, ethers.parseEther("1000"));
  // await tokenB.approve(dexAddr, ethers.parseEther("1000"));
  // // await semiFungible.setApprovalForAll(dexAddr, true);

  // await dex.addLiquidity(ethers.parseEther("100"), ethers.parseEther("100"));

  // console.log(`ReserveA: `, Number(await dex.reserveA()) / Math.pow(10, 18));
  // console.log(`ReserveB: `, Number(await dex.reserveB()) / Math.pow(10, 18));

  // // await dex.addLiquidityERC1155(
  // //   ethers.parseEther("100"),
  // //   ethers.parseEther("1")
  // // );

  // // console.log(`Reserve Gold: ${Number(await dex.GOLD())}`);
  // // console.log(`Reserve NFT: ${Number(await dex.NFT())}`);

  // console.log("Swapping");
  // await dex.swap(tokenAAddr, ethers.parseEther("10"));

  // balanceA = await tokenA.balanceOf(wallet.address);
  // balanceB = await tokenB.balanceOf(wallet.address);

  // console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  // console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
