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
  solidity: "0.8.14",
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
    }
  },
};
