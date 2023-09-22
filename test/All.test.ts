import { deployments, ethers } from 'hardhat'
import { assert, expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import {
  IERC20Metadata,
  IERC20Metadata__factory,
  Item,
  Item__factory,
  Treasury,
  Treasury__factory,
  FixStakingStrategy,
  FixStakingStrategy__factory,
  NftToken,
  NftToken__factory,
} from '../typechain-types'
import { ELCT, USDT } from '../constants/addresses'
import ERC20Minter from './utils/ERC20Minter'
import { BigNumber } from 'ethers'
import { time } from '@nomicfoundation/hardhat-network-helpers'

const TEST_DATA = {
  payTokens: [
    USDT, //
  ],
  nftTokens: [
    'DubaiNftToken', //
    'ChinaNftToken',
  ],
}

describe(`AllTest`, () => {
  let initSnapshot: string
  let productOwner: SignerWithAddress
  let server: SignerWithAddress
  let user: SignerWithAddress
  let treasury: Treasury

  before(async () => {
    const accounts = await ethers.getSigners()
    productOwner = accounts[0]
    server = accounts[1]
    user = accounts[9]
    await deployments.fixture()
    const TreasuryDeployment = await deployments.get('Treasury')
    treasury = Treasury__factory.connect(TreasuryDeployment.address, productOwner)
    initSnapshot = await ethers.provider.send('evm_snapshot', [])
  })

  afterEach(async () => {
    await ethers.provider.send('evm_revert', [initSnapshot])
    initSnapshot = await ethers.provider.send('evm_snapshot', [])
  })

  for (const nftTokenTag of TEST_DATA.nftTokens) {
    describe(`NFT token ${nftTokenTag}`, () => {
      let nftToken: NftToken

      beforeEach(async () => {
        const NftTokenDeployment = await deployments.get(nftTokenTag)
        nftToken = NftToken__factory.connect(
          NftTokenDeployment.address,
          user,
        )
      })

      for (const tokenAddress of TEST_DATA.payTokens) {
        describe(`Token ${tokenAddress}`, () => {
          let token: IERC20Metadata
          let mintedPayTokensAmount: BigNumber

          beforeEach(async () => {
            token = IERC20Metadata__factory.connect(tokenAddress, user)
            mintedPayTokensAmount = await ERC20Minter.mint(token.address, user.address, 100000)
          })

          it(`test`, async () => {
            
          })
        })
      }
    })
  }
})
