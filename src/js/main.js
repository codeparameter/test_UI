
import { ethers, provider, accounts } from "./ethers.js";
import { coursetroContract } from "./coursetroContract.js";


const main = async () => {
  const balance = await provider.getBalance(accounts[0]);
  console.log(balance);
  console.log(balance.toString());
  console.log(balance.add(1).toString());
  console.log(ethers.utils.formatEther(balance));

  await coursetroContract();
};

main();
