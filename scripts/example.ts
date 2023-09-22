import { ethers } from "ethers"
import { UsersMarketplace__factory } from "../typechain-types";

async function main() {
  let {a} = await UsersMarketplace__factory.connect().sellInfo()
  a.payToken_;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});