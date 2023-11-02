import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    mumbai: {
      url: `${process.env.MUMBAI_RPC_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    redbelly: {
      url: `${process.env.RBN_RPC_URL}`,
      chainId: Number(process.env.CHAIN_ID),
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
};

export default config;
