import { getContracts } from "./utils"

export async function main() {

  if (
    !process.env.NDR_ADDRESS ||
    !process.env.EXCHANGE_ADDRESS
  ) {
    throw new Error("Required contracts must be deployed previous this contract")
  }

  await getContracts();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});