import { ethers } from "hardhat";
import { updateConfig } from "./utils";
import * as CmJson from "../artifacts/contracts/ChatMind.sol/ChatMind.json";
import * as CmrJson from "../artifacts/contracts/ChatMindReward.sol/ChatMindReward.json";

async function main() {
  const chatMindContract = "ChatMind";
  const chatMindRewardContract = "ChatMindReward";
  const deployer = (await ethers.getSigners())[0];
  const balance = await deployer.getBalance();

  console.log("Deploying with account:", deployer.address);
  console.log(`Account balance: ${ethers.utils.formatEther(balance)} ETH`);

  const ChatMind = await ethers.getContractFactory(chatMindContract);
  const chatMind = await ChatMind.deploy(10000000);
  await chatMind.deployed();
  console.log(chatMindContract, chatMind.address);

  const ChatMindReward = await ethers.getContractFactory(
    chatMindRewardContract
  );
  const chatMindReward = await ChatMindReward.deploy(
    chatMind.address,
    deployer.address
  );
  await chatMindReward.deployed();
  console.log(chatMindRewardContract, chatMindReward.address);

  updateConfig([
    { address: chatMind.address, contractJson: CmJson },
    { address: chatMindReward.address, contractJson: CmrJson },
  ]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
