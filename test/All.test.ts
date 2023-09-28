import { deployments, ethers } from 'hardhat'
import { assert, expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import {
  IERC20Metadata,
  IERC20Metadata__factory,
  Treasury,
  Treasury__factory,
  NftToken,
  NftToken__factory,
  ProductOwnerMarketplace,
  ProductOwnerMarketplace__factory,
  UsersMarketplace,
  UsersMarketplace__factory,
  NftReferalStaking,
  NftReferalStaking__factory,
} from '../typechain-types'
import { USDT } from '../constants/addresses'
import ERC20Minter from './utils/ERC20Minter'
import { BigNumber } from 'ethers'
import { time } from '@nomicfoundation/hardhat-network-helpers'
import crypto from 'node:crypto'
import { ServerSigUtils } from './ServerSigUtils'

const TEST_DATA = {
  payTokens: [
    USDT, //
  ],
  nftTokens: [
    'DubaiNftToken', //
    // 'ChinaNftToken',
  ],
}

describe(`AllTest`, () => {
  let initSnapshot: string
  let productOwner: SignerWithAddress
  let server: SignerWithAddress
  let user: SignerWithAddress
  let treasury: Treasury
  let productOwnerMarketplace: ProductOwnerMarketplace
  let usersMarketplace: UsersMarketplace
  let nftReferalStaking: NftReferalStaking

  before(async () => {
    const accounts = await ethers.getSigners()
    productOwner = accounts[0]
    server = accounts[1]
    user = accounts[9]

    await deployments.fixture()

    const TreasuryDeployment = await deployments.get('Treasury')
    treasury = Treasury__factory.connect(TreasuryDeployment.address, productOwner)

    const ProductOwnerMarketplaceDeployment = await deployments.get('ProductOwnerMarketplace')
    productOwnerMarketplace = ProductOwnerMarketplace__factory.connect(
      ProductOwnerMarketplaceDeployment.address,
      productOwner,
    )

    const UsersMarketplaceDeployment = await deployments.get('UsersMarketplace')
    usersMarketplace = UsersMarketplace__factory.connect(
      UsersMarketplaceDeployment.address,
      productOwner,
    )

    const NftReferalStakingDeployment = await deployments.get('NftReferalStaking')
    nftReferalStaking = NftReferalStaking__factory.connect(
      NftReferalStakingDeployment.address,
      productOwner,
    )

    initSnapshot = await ethers.provider.send('evm_snapshot', [])
  })

  afterEach(async () => {
    await ethers.provider.send('evm_revert', [initSnapshot])
    initSnapshot = await ethers.provider.send('evm_snapshot', [])
  })

  for (const nftTokenTag of TEST_DATA.nftTokens) {
    describe(`NFT payToken ${nftTokenTag}`, () => {
      let nftToken: NftToken

      beforeEach(async () => {
        const NftTokenDeployment = await deployments.get(nftTokenTag)
        nftToken = NftToken__factory.connect(NftTokenDeployment.address, user)
      })

      for (const payTokenAddress of TEST_DATA.payTokens) {
        describe(`Token ${payTokenAddress}`, () => {
          let payToken: IERC20Metadata
          let mintedPayTokensAmount: BigNumber

          beforeEach(async () => {
            payToken = IERC20Metadata__factory.connect(payTokenAddress, user)
            mintedPayTokensAmount = await ERC20Minter.mint(payToken.address, user.address, 100000)
            await payToken
              .connect(user)
              .approve(productOwnerMarketplace.address, mintedPayTokensAmount)
          })

          xit(`test`, async () => {
            const nftId = 0
            const stakeId = 0
            await productOwnerMarketplace.connect(user).buy(nftToken.address, payToken.address)
            await nftToken.connect(user).approve(nftReferalStaking.address, nftId)
            await nftReferalStaking.connect(user).stake(nftToken.address, nftId)
            await time.increase(366 * 24 * 60 * 60)
            await nftReferalStaking.connect(user).unstake(stakeId)
            await expect(
              nftReferalStaking.connect(user).stake(nftToken.address, nftId),
            ).to.be.revertedWith('already staked!')
          })

          it(`signed buy`, async () => {
            const discount = 1000
            const uuidHash = ethers.utils.solidityKeccak256(['string'], [crypto.randomUUID()])
            const currentTimestamp = (await ethers.provider.getBlock('latest')).timestamp
            const exireiesTimestamp = currentTimestamp + 24 * 60 * 60

            const signature = await ServerSigUtils.signDiscountedBuy({
              signer: server,
              recipient: user.address,
              nftToken: nftToken.address,
              discount,
              uuidHash,
              exireiesTimestamp
            })

            await productOwnerMarketplace
              .connect(user)
              .discountedBuy(
                nftToken.address,
                payToken.address,
                discount,
                uuidHash,
                exireiesTimestamp,
                signature
              )
              console.log('aw16')
          })
          
          it(`error signed buy`, async () => {
            const discount = 1000
            const uuidHash = ethers.utils.solidityKeccak256(['string'], [crypto.randomUUID()])
            const currentTimestamp = (await ethers.provider.getBlock('latest')).timestamp
            const exireiesTimestamp = currentTimestamp + 24 * 60 * 60

            const signature = await ServerSigUtils.signDiscountedBuy({
              signer: server,
              recipient: user.address,
              nftToken: nftToken.address,
              discount,
              uuidHash,
              exireiesTimestamp
            })

            await expect(productOwnerMarketplace
              .connect(user)
              .discountedBuy(
                nftToken.address,
                payToken.address,
                discount + 1000,
                uuidHash,
                exireiesTimestamp,
                signature
              )).to.be.revertedWith('signature!')
          })
        })
      }
    })
  }
})
