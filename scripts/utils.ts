import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, ContractFactory } from "ethers";
import { ethers, network, upgrades } from "hardhat";

const networkName = network.name;
const LOCAL_NETWORKS = ['hardhat', 'localhost', 'ganache'];

type DeployRequirementsResponse = {
  NDRAddress: string
  ExchangeAddress: string
}

type GetContractsResponse = DeployRequirementsResponse & {
  contractAddress: string
}

export async function getContracts(): Promise<GetContractsResponse> {
  let contracts = {
    NDRAddress: process.env.NDR_ADDRESS,
    ExchangeAddress: process.env.EXCHANGE_ADDRESS,
  }

  if (LOCAL_NETWORKS.includes(networkName)) {
    console.log("\x1b[32m%s\x1b[0m", "Deploying Development Contracts:");
    contracts = await deployRequirements();
  }

    const contractAddress: string = await deployContract("NDR", [
    contracts.NDRAddress,
    contracts.ExchangeAddress
  ], true);

  return {
    ...contracts,
    contractAddress
  };
}

async function deployRequirements(): Promise<DeployRequirementsResponse> {
  const [owner]: SignerWithAddress[] = await ethers.getSigners();
  const NDRAddress: string = await deployContract("NDR", undefined, false);
  const ExchangeAddress = await deployContract("Exchange", [owner.address, 30, 100, NDRAddress]);

  return {
    NDRAddress,
    ExchangeAddress
  };
}

async function deployContract(contractName: string, params: any[] = [], upgradable: boolean = true): Promise<string> {
  console.log("\x1b[34m%s\x1b[0m", `Deploying ${contractName}...`);
  const MockContract: ContractFactory = await ethers.getContractFactory(contractName);
  let mockedContract: Contract;
  if (upgradable)
    mockedContract = await upgrades.deployProxy(MockContract, params);
  else
    mockedContract = await MockContract.deploy(...params);

  await mockedContract.deployed()

  console.log("\x1b[34m%s\x1b[0m", `${contractName} Deployed:`, mockedContract.address);
  console.log("\x1b[34m%s\x1b[0m", "Owner:", mockedContract.deployTransaction.from);
  return mockedContract.address;
}
