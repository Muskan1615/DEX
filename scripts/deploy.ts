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

  const ERC20DEX = await ethers.getContractFactory("ERC20DEX");
  const erc20DEX = await ERC20DEX.deploy(tokenAAddr, tokenBAddr);
  erc20DEX.waitForDeployment;
  const erc20DEXAddr = await erc20DEX.getAddress();
  console.log("ERC20DEX deployed to:", erc20DEXAddr);

  const ERC1155DEX = await ethers.getContractFactory("ERC1155DEX");
  const erc1155DEX = await ERC1155DEX.deploy(tokenERC1155Addr);
  erc1155DEX.waitForDeployment;
  const erc1155DEXAddr = await erc1155DEX.getAddress();
  console.log("ERC1155DEX deployed to:", erc1155DEXAddr);

  console.log("ERC20 DEX Implementation:");
  console.log("ERC20 Balances Before Minting:");

  let balanceA = await tokenA.balanceOf(wallet.address);
  let balanceB = await tokenB.balanceOf(wallet.address);

  console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);

  console.log("ERC20 Balances After Minting:");

  await tokenA.mint(wallet.address, ethers.parseEther("200"));
  await tokenB.mint(wallet.address, ethers.parseEther("200"));

  balanceA = await tokenA.balanceOf(wallet.address);
  balanceB = await tokenB.balanceOf(wallet.address);

  console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);

  console.log("Approving ERC20DEX To Perform Trades:");

  await tokenA.approve(erc20DEXAddr, ethers.parseEther("1000"));
  await tokenB.approve(erc20DEXAddr, ethers.parseEther("1000"));

  console.log("Adding Liquidity:");

  await erc20DEX.addLiquidity(
    ethers.parseEther("100"),
    ethers.parseEther("100")
  );

  console.log("Reserve Balances After Adding Liquidity:");

  console.log(
    `ReserveA: `,
    Number(await erc20DEX.reserveA()) / Math.pow(10, 18)
  );
  console.log(
    `ReserveB: `,
    Number(await erc20DEX.reserveB()) / Math.pow(10, 18)
  );

  console.log("Swapping ERC20 Tokens:");

  await erc20DEX.swap(tokenAAddr, ethers.parseEther("10"));

  console.log("ERC20 Balances After Swapping:");

  balanceA = await tokenA.balanceOf(wallet.address);
  balanceB = await tokenB.balanceOf(wallet.address);

  console.log(`TokenA Balance: ${Number(balanceA) / Math.pow(10, 18)}`);
  console.log(`TokenB Balance: ${Number(balanceB) / Math.pow(10, 18)}`);

  console.log("Reserve Balances After Swapping:");

  console.log(
    `ReserveA: `,
    Number(await erc20DEX.reserveA()) / Math.pow(10, 18)
  );
  console.log(
    `ReserveB: `,
    Number(await erc20DEX.reserveB()) / Math.pow(10, 18)
  );

  console.log("ERC1155 DEX Implementation:");
  console.log("ERC1155 Balances Before Minting:");

  let balances = await tokenERC1155.balanceOfBatch(
    [wallet.address, wallet.address, wallet.address, wallet.address],
    [1, 2, 3, 4]
  );
  balances.forEach((balance, index) => {
    console.log(`Token ${index + 1}: ${Number(balance)}`);
  });

  console.log("ERC1155 Balances After Minting:");

  await tokenERC1155.mintBatch([1, 2, 3, 4], [100, 200, 50, 100], "0x00");

  balances = await tokenERC1155.balanceOfBatch(
    [wallet.address, wallet.address, wallet.address, wallet.address],
    [1, 2, 3, 4]
  );
  balances.forEach((balance, index) => {
    console.log(`Token ${index + 1}: ${Number(balance)}`);
  });

  console.log("Approving ERC1155DEX To Perform Trades:");

  await tokenERC1155.setApprovalForAll(erc1155DEXAddr, true);

  console.log("Adding Liquidity:");

  await erc1155DEX.addLiquidity([1, 2, 3, 4], [10, 20, 15, 20]);

  console.log("Reserve Balances After Adding Liquidity:");

  console.log(`Reserve 1: ${Number(await erc1155DEX.reserves(1))}`);
  console.log(`Reserve 2: ${Number(await erc1155DEX.reserves(2))}`);
  console.log(`Reserve 3: ${Number(await erc1155DEX.reserves(3))}`);
  console.log(`Reserve 4: ${Number(await erc1155DEX.reserves(4))}`);

  console.log("Swapping ERC1155 Tokens:");

  await erc1155DEX.swap(1, 5, 2);

  console.log("ERC1155 Balances After Swapping:");

  balances = await tokenERC1155.balanceOfBatch(
    [wallet.address, wallet.address, wallet.address, wallet.address],
    [1, 2, 3, 4]
  );
  balances.forEach((balance, index) => {
    console.log(`Token ${index + 1}: ${Number(balance)}`);
  });

  console.log("Reserve Balances After Swapping:");

  console.log(`Reserve 1: ${Number(await erc1155DEX.reserves(1))}`);
  console.log(`Reserve 2: ${Number(await erc1155DEX.reserves(2))}`);
  console.log(`Reserve 3: ${Number(await erc1155DEX.reserves(3))}`);
  console.log(`Reserve 4: ${Number(await erc1155DEX.reserves(4))}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
