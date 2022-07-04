import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import '@typechain/hardhat'
import { task } from "hardhat/config";

require("dotenv").config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address + ': ', hre.ethers.utils.formatEther(await account.getBalance()));
  }
});

module.exports = {
  solidity: "0.8.6",
  settings: {
    optimizer: {
      enabled: true,
      runs: 100,
    }
  },
  networks: {
    ganache: {
      url: `http://127.0.0.1:7545`
    },
    woonkly: {
      url: `http://ec2-54-93-234-47.eu-central-1.compute.amazonaws.com:8545`,
      chainId: 2023,
      gas: 0x47b760,
      gasPrice: 0x34630b8a00,
      blockGasLimit: 0x47b760,
      allowUnlimitedContractSize: true,
      timeout: 1800000
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      timeout: 200000
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
    },
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true
    },
    rinkeby: {
      url: process.env.RINKEBY_NETWORK_URL || "",
      accounts:
        process.env.OWNER_PRIVATE_KEY !== undefined ? [process.env.OWNER_PRIVATE_KEY, process.env.BUYER_PRIVATE_KEY] : [],
    }
  },
};
