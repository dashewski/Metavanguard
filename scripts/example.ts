import { ethers } from "ethers"
import { NftReferalStaking__factory, NftTokensObserver__factory, UsersMarketplace__factory } from "../typechain-types";

async function main() {
  let provider: ethers.providers.JsonRpcProvider

  // Nft Referal Staking
  let referalStakingAddress: string
  const nftReferalStaking = NftReferalStaking__factory.connect(referalStakingAddress,provider)

  nftReferalStaking.on(nftReferalStaking.filters.Stake(), (stakingId, owner, nftToken, nftId) => {
    // New Referal staking
  })
  nftReferalStaking.on(nftReferalStaking.filters.Unstake(), (stakingId, owner, nftToken, nftId) => {
    // Close Referal staking
  })
  nftReferalStaking.on(nftReferalStaking.filters.Transfer(), (from, to, nftId) => {
    // Change staking owner
  })

  // Nft Tokens Observer
  
  let nftTokensObserverAddress: string
  const nftTokensObserver = NftTokensObserver__factory.connect(nftTokensObserverAddress,provider)

  nftTokensObserver.on(nftTokensObserver.filters.ChangeOwner(), (nftToken, nftId, from, to) => {

  })
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});